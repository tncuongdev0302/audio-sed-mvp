"""Audio SED MVP — FastAPI backend."""

import tempfile
from pathlib import Path

import librosa
from fastapi import FastAPI, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from yamnet_inference import analyze, load_model
from cough_recommendation import (
    CoughAssessment, classify_and_recommend,
    COUGH_TYPES, DURATION_CATEGORIES, SUBJECT_GROUPS, RED_FLAG_LABELS,
)
from cough_type_v2 import classify_cough_type
from routes.intake import router as intake_router
from routes.context import router as context_router
from routes.sleep import router as sleep_router
from routes.alerts import router as alerts_router
from routes.food import router as food_router
from routes.checkout import router as checkout_router
from routes.products import router as products_router

STORAGE_DIR = Path(__file__).parent / "storage" / "real_wav"
RECORDINGS_DIR = Path(__file__).parent / "storage" / "recordings"
FRONTEND_DIR = Path(__file__).parent.parent / "frontend"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(intake_router)
app.include_router(context_router)
app.include_router(sleep_router)
app.include_router(alerts_router)
app.include_router(food_router)
app.include_router(checkout_router)
app.include_router(products_router)


@app.on_event("startup")
def startup():
    STORAGE_DIR.mkdir(parents=True, exist_ok=True)
    RECORDINGS_DIR.mkdir(parents=True, exist_ok=True)
    load_model()


@app.get("/api/samples")
def list_samples():
    return sorted(f.name for f in STORAGE_DIR.glob("*.wav"))


@app.get("/api/samples/{filename}")
def get_sample(filename: str):
    if ".." in filename or "/" in filename or "\\" in filename:
        raise HTTPException(400, "Invalid filename")
    path = STORAGE_DIR / filename
    if not path.is_file():
        raise HTTPException(404, "File not found")
    return FileResponse(path, media_type="audio/wav")


@app.post("/api/analyze")
async def analyze_audio(file: UploadFile, mode: str = "v1"):
    tmp_path = None
    try:
        data = await file.read()
        ext = Path(file.filename or "audio.wav").suffix or ".wav"
        with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
            tmp.write(data)
            tmp_path = Path(tmp.name)
        # Save recording for debugging
        from datetime import datetime
        save_name = datetime.now().strftime("%Y%m%d_%H%M%S") + ext
        (RECORDINGS_DIR / save_name).write_bytes(data)
        audio_np, sr = librosa.load(str(tmp_path), sr=16000, mono=True)
        result = analyze(audio_np, sr)
        # V2: add cough type classification if cough detected
        if mode == "v2" and result["has_cough"]:
            result["cough_type_analysis"] = classify_cough_type(audio_np, sr)

        if mode == "v2":
            has_cough = result["has_cough"]
            events = result["events"]
            has_wheeze = any(e["class"] == "Wheeze" for e in events)
            has_snoring = any(e["class"] == "Snoring" for e in events)

            # 1. Sinus Risk
            wet_prob = 0.0
            if has_cough and "cough_type_analysis" in result:
                wet_prob = result["cough_type_analysis"]["probabilities"].get("wet", 0.0)
            elif has_cough:
                wet_prob = 0.5

            risk_percent = round(wet_prob * 100)
            if risk_percent >= 70:
                risk_level = "CAO"
            elif risk_percent >= 30:
                risk_level = "TRUNG BÌNH"
            else:
                risk_level = "THẤP"

            result["sinus_risk"] = {
                "percent": risk_percent,
                "level": risk_level,
                "label": f"Nguy cơ ứ đọng dịch xoang sau: {risk_percent}% ({risk_level})"
            }

            # 2. Airway Obstruction
            if has_wheeze:
                obstruction_level = "Cao"
            elif has_snoring:
                obstruction_level = "Trung bình"
            else:
                obstruction_level = "Thấp"

            result["obstruction"] = {
                "level": obstruction_level
            }

            # 3. Treatment Checklist
            checklist = []
            if has_cough:
                is_wet = False
                if "cough_type_analysis" in result:
                    is_wet = result["cough_type_analysis"]["cough_type"] == "wet"

                if is_wet:
                    checklist = [
                        {"text": "Rửa mũi bằng nước muối sinh lý ấm (Ưu tiên)", "type": "success"},
                        {"text": "Súc họng bằng dung dịch sát khuẩn miệng", "type": "success"},
                        {"text": "Uống nhiều nước ấm và hạn chế ngồi điều hòa lạnh", "type": "neutral"}
                    ]
                else:
                    checklist = [
                        {"text": "Sử dụng kẹo ngậm giảm ho hoặc mật ong ấm", "type": "success"},
                        {"text": "Súc họng bằng nước muối ấm sát khuẩn", "type": "success"},
                        {"text": "Uống nhiều nước ấm và giữ ấm vùng cổ họng", "type": "neutral"}
                    ]
            elif has_wheeze:
                checklist = [
                    {"text": "Tránh tiếp xúc dị nguyên (bụi bẩn, phấn hoa, lông thú)", "type": "success"},
                    {"text": "Sử dụng thuốc giãn phế quản cắt cơn (nếu được chỉ định)", "type": "success"},
                    {"text": "Giữ tư thế ngồi thẳng giúp mở rộng đường thở", "type": "neutral"}
                ]
            elif has_snoring:
                checklist = [
                    {"text": "Nằm nghiêng khi ngủ giúp giảm tắc nghẽn hô hấp", "type": "success"},
                    {"text": "Hạn chế dùng chất kích thích hoặc ăn quá no sát giờ ngủ", "type": "success"},
                    {"text": "Vệ sinh thông thoáng mũi trước khi đi ngủ", "type": "neutral"}
                ]
            else:
                checklist = [
                    {"text": "Duy trì chế độ uống đủ nước ấm hàng ngày", "type": "success"},
                    {"text": "Luyện tập các bài tập hít thở sâu nâng cao thể tích phổi", "type": "success"},
                    {"text": "Giữ ấm cơ thể khi thời tiết thay đổi đột ngột", "type": "neutral"}
                ]
            result["treatment_checklist"] = checklist

            # 4. Expert Advice
            if has_cough:
                is_wet = False
                if "cough_type_analysis" in result:
                    is_wet = result["cough_type_analysis"]["cough_type"] == "wet"
                if is_wet:
                    advice = f"Lời khuyên của chuyên gia: Phân tích tần số âm cho thấy tiếng ho có độ ẩm cao (xác suất ho có đờm là {risk_percent}%), dấu hiệu dịch tích tụ đường hô hấp/xoang sau. Hãy thực hiện rửa mũi và xịt kháng viêm sát khuẩn. Nếu tình trạng ho kéo dài trên 3 ngày, vui lòng liên hệ bác sĩ để được tư vấn điều trị."
                else:
                    dry_prob = round((result["cough_type_analysis"]["probabilities"].get("dry", 0.5) if "cough_type_analysis" in result else 0.5) * 100)
                    advice = f"Lời khuyên của chuyên gia: Phân tích tần số âm phát hiện tiếng ho khan với xác suất {dry_prob}%, thường là biểu hiện kích ứng đường hô hấp do dị ứng thời tiết hoặc môi trường khói bụi. Hãy súc họng nước muối, giữ ấm cổ và tránh máy lạnh phả thẳng vào mũi/họng."
            elif has_wheeze:
                advice = "Lời khuyên của chuyên gia: Phát hiện âm thở khò khè (Wheeze). Đây là dấu hiệu co thắt phế quản/đường thở bị hẹp. Hãy giữ ấm phòng ngủ, tránh xa khói thuốc lá và bụi mịn. Cần thăm khám bác sĩ chuyên khoa hô hấp nếu cơn khò khè xuất hiện thường xuyên hoặc kèm khó thở."
            elif has_snoring:
                advice = "Lời khuyên của chuyên gia: Phát hiện tiếng ngáy (Snoring). Hiện tượng này xảy ra do mô mềm đường hô hấp trên rung động khi không khí đi qua bị cản trở. Khuyến nghị ngủ tư thế nằm nghiêng, giữ gối cao vừa phải và duy trì cân nặng hợp lý để cải thiện tình trạng."
            else:
                advice = "Lời khuyên của chuyên gia: Không phát hiện bất thường về tiếng ho, thở khò khè hay ngáy trong bản ghi âm. Hệ hô hấp của bạn đang ở trạng thái ổn định. Hãy tiếp tục duy trì thói quen tập thể dục, vệ sinh mũi họng sạch sẽ hàng ngày."
            result["expert_advice"] = advice

        return result
    except Exception as e:
        raise HTTPException(400, str(e))
    finally:
        if tmp_path and tmp_path.exists():
            tmp_path.unlink()


# --- Cough Classification & Recommendation ---

class AssessmentInput(BaseModel):
    cough_type: str = "dry"
    duration: str = "acute"
    subject: str = "adult"
    red_flags: list[str] = []
    night_cough: bool = False
    post_flu: bool = False
    cough_frequency: str = "moderate"
    # From audio analysis (optional, frontend passes these)
    audio_has_cough: bool = True
    audio_cough_count: int = 1
    audio_confidence: float = 0.5


@app.get("/api/recommendation/options")
def get_recommendation_options():
    """Return all options for the assessment form."""
    return {
        "cough_types": COUGH_TYPES,
        "durations": DURATION_CATEGORIES,
        "subjects": SUBJECT_GROUPS,
        "red_flags": RED_FLAG_LABELS,
    }


@app.post("/api/recommendation")
def get_recommendation(input: AssessmentInput):
    """Classify cough and return recommendations."""
    assessment = CoughAssessment(
        cough_type=input.cough_type,
        duration=input.duration,
        subject=input.subject,
        red_flags=input.red_flags,
        night_cough=input.night_cough,
        post_flu=input.post_flu,
        cough_frequency=input.cough_frequency,
    )
    return classify_and_recommend(
        assessment,
        audio_has_cough=input.audio_has_cough,
        audio_cough_count=input.audio_cough_count,
        audio_confidence=input.audio_confidence,
    )


# Static files mounted last so /api/* routes take priority
if FRONTEND_DIR.is_dir():
    app.mount("/", StaticFiles(directory=str(FRONTEND_DIR), html=True), name="frontend")
