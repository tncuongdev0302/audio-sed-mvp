"""Context aggregation routes."""

from fastapi import APIRouter, HTTPException

from models.user import get_user
from services.context_aggregator import fetch_weather

router = APIRouter(prefix="/api/v1/context", tags=["context"])


@router.get("/{user_id}")
async def get_user_context(user_id: str):
    user = get_user(user_id)
    if not user:
        raise HTTPException(404, detail="User not found")

    weather = await fetch_weather(user.lat, user.long)
    pm25 = weather.get("pm25", 0)
    humidity = weather.get("humidity", 50)

    # Calculate score based on weather and disease tags
    score = 85
    status = "TỐT"
    description = "Dựa trên hồ sơ bệnh lý của bạn, các chỉ số ngoại cảnh hôm nay rất lý tưởng. Nguy cơ tái phát đợt cấp ở mức thấp."
    advice = "AI khuyên dùng: Nên bật máy tạo độ ẩm trong phòng kín và dùng xịt mũi biển sâu trước khi ra ngoài."

    if pm25 > 150:
        score = 45
        status = "CẢNH BÁO"
        description = "Chất lượng không khí xấu (PM2.5 > 150) dễ kích ứng niêm mạc xoang. Nguy cơ bùng phát đợt cấp CAO."
        advice = "AI khuyên dùng: Đeo khẩu trang N95 khi ra ngoài, bật máy tạo ẩm và rửa mũi bằng nước muối sinh lý ấm."
    elif pm25 > 50 or humidity < 60:
        score = 70
        status = "TRUNG BÌNH"
        description = "Chất lượng không khí ở mức trung bình. Độ ẩm hơi thấp, cần lưu ý giữ ẩm niêm mạc mũi."
        advice = "AI khuyên dùng: Sử dụng xịt mũi nước biển sâu Xisat để duy trì độ ẩm cho niêm mạc."

    # Evaluate dynamic rules/alerts
    from services.rule_engine import evaluate_rules
    alerts = evaluate_rules(user.model_dump(), weather)

    return {
        "user_id": user_id,
        "name": user.name,
        "weather": weather,
        "disease_tags": user.disease_tags,
        "symptoms": user.symptoms,
        "vitals": user.vitals,
        "message_vi": "Dữ liệu ngữ cảnh sức khỏe",
        "sinus_score": score,
        "sinus_status": status,
        "sinus_description": description,
        "ai_advice": advice,
        "alerts": alerts,
    }
