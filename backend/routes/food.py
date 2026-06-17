"""Food scan routes."""

import time
from typing import Optional

from fastapi import APIRouter, HTTPException, UploadFile, Form

from models.user import get_user
from services.food_detector import detect
from services.health_risk import assess_health_risk

router = APIRouter(prefix="/api/v1/food", tags=["food"])

_MOCK_FOOD_OPTIONS = [
    {'key': 'phoga', 'name': 'Phở Gà (Chicken Noodle)'},
    {'key': 'haisan', 'name': 'Lẩu Hải Sản Cay'},
    {'key': 'dalanh', 'name': 'Kem Trái Cây Lạnh'},
]

_MOCK_FOOD_TAGS = {
    'phoga': [
        {'text': 'Gừng - Tốt', 'type': 'success'},
        {'text': 'Hành - Tốt', 'type': 'success'},
        {'text': 'Tiêu - Hạn chế', 'type': 'error'},
        {'text': 'Nước dùng gà - Tốt', 'type': 'success'},
        {'text': 'Bánh phở - Trung tính', 'type': 'neutral'},
    ],
    'haisan': [
        {'text': 'Tôm, Cua - Kích ứng', 'type': 'error'},
        {'text': 'Ớt - Kích ứng', 'type': 'error'},
        {'text': 'Rau cải - Tốt', 'type': 'success'},
        {'text': 'Nấm - Trung tính', 'type': 'neutral'},
    ],
    'dalanh': [
        {'text': 'Đá lạnh - Co mạch', 'type': 'error'},
        {'text': 'Kem - Trung tính', 'type': 'neutral'},
        {'text': 'Trái cây - Tốt', 'type': 'success'},
    ],
}

@router.get("/options")
def get_food_options():
    return {"options": _MOCK_FOOD_OPTIONS}

@router.post("/scan")
async def food_scan(file: UploadFile, user_id: Optional[str] = Form(None), food_key: Optional[str] = Form(None)):
    """Scan food image → detect foods → assess health risk."""
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(400, "File must be an image")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(400, "Empty file")

    # Save received image for debugging
    try:
        import os
        os.makedirs("storage", exist_ok=True)
        with open("storage/debug_received_image.jpg", "wb") as f_debug:
            f_debug.write(image_bytes)
        print(f"[DEBUG] Saved uploaded food image of size {len(image_bytes)} bytes to storage/debug_received_image.jpg")
    except Exception as e:
        print(f"[DEBUG] Failed to save uploaded food image: {e}")

    start = time.time()
    foods = detect(image_bytes)
    inference_time_ms = (time.time() - start) * 1000

    # Không phát hiện đồ ăn
    if not foods:
        return {
            "foods": [],
            "total_nutrition": {"Calories": 0, "Fat": 0, "Saturates": 0, "Sugar": 0, "Salt": 0},
            "risk_alerts": [],
            "food_tags": [],
            "advice_text": "",
            "message_vi": "Không tìm thấy thông tin thức ăn trên ảnh. Bạn cần kiểm tra lại đã đưa đúng camera vào món ăn chưa.",
            "inference_time_ms": round(inference_time_ms, 1),
        }

    # Health risk assessment
    user_profile = {}
    if user_id:
        user = get_user(user_id)
        if user:
            user_profile = user.model_dump()

    risk_result = assess_health_risk(foods, user_profile)
    risk_alerts = risk_result["risk_alerts"]
    
    food_tags = _MOCK_FOOD_TAGS.get(food_key) if food_key else [{'text': 'Thành phần chính - Tốt', 'type': 'success'}]
    
    advice_text = 'Món ăn không chứa thành phần gây kích ứng, an toàn để sử dụng.'
    if food_key == 'phoga':
        advice_text = 'Khuyên dùng: Gừng và hành lá trong nước phở giúp giữ ấm cơ thể, tăng cường tuần hoàn niêm mạc xoang. Hạn chế tối đa thêm tương ớt và hạt tiêu vì chất cay nóng kích hoạt phản ứng Histamine gây co thắt và nghẹt mũi nặng hơn.'
    elif any(a.get('severity') == 'danger' for a in risk_alerts):
        advice_text = 'Phát hiện có thành phần nguy cơ cao gây viêm hoặc kích ứng đường hô hấp. Khuyên dùng hạn chế tối đa hoặc thay thế bằng món ăn lành tính hơn.'
    elif any(a.get('severity') == 'warning' for a in risk_alerts):
        advice_text = 'Món ăn có thành phần cần kiểm soát liều lượng đối với tình trạng sức khỏe hiện tại của bạn. Vui lòng ăn với khẩu phần vừa phải.'

    return {
        "foods": foods,
        "total_nutrition": risk_result["total_nutrition"],
        "risk_alerts": risk_alerts,
        "food_tags": food_tags,
        "advice_text": advice_text,
        "inference_time_ms": round(inference_time_ms, 1),
    }
