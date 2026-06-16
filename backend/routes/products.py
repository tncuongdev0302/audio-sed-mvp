"""Products API routes."""

from fastapi import APIRouter
from typing import Optional

router = APIRouter(prefix="/api/v1/products", tags=["products"])

_MOCK_PRODUCTS = {
    'dry': [
      {
        "name": 'Viên ngậm thảo dược bổ phế Bảo Thanh',
        "brand": 'Hoa Linh (Việt Nam)',
        "price": '36.000đ',
        "unit": 'Hộp 5 vỉ x 4 viên',
        "iconType": 'pill',
        "desc": 'Bổ phế, trừ ho khan, dịu họng, loãng đờm',
        "tag": 'Bán chạy nhất',
      },
      {
        "name": 'Siro ho thảo dược Prospan 100ml',
        "brand": 'Engelhard (Đức)',
        "price": '82.000đ',
        "unit": 'Chai 100ml',
        "iconType": 'siro',
        "desc": 'Làm loãng dịch nhầy, dịu phế quản co thắt',
        "tag": 'Dược sĩ khuyên dùng',
      },
      {
        "name": 'Xịt họng sát khuẩn Keo Ong Propobee',
        "brand": 'DK Pharma (Việt Nam)',
        "price": '115.000đ',
        "unit": 'Lọ 15ml',
        "iconType": 'spray',
        "desc": 'Sát khuẩn tại chỗ, dịu nhanh cơn ho kích ứng',
        "tag": 'Công nghệ mới',
      },
    ],
    'phlegm': [
      {
        "name": 'Siro ho trẻ em Prospan',
        "brand": 'Engelhard (Đức)',
        "price": '82.000đ',
        "unit": 'Chai 100ml',
        "iconType": 'siro',
        "desc": 'Chiết xuất lá thường xuân hỗ trợ long đờm hiệu quả',
        "tag": 'Nhập khẩu Đức',
      },
      {
        "name": 'Viên sủi long đờm nhầy ACC200',
        "brand": 'Sandoz (Đức)',
        "price": '68.000đ',
        "unit": 'Hộp 20 viên',
        "iconType": 'pill',
        "desc": 'Làm loãng đờm đặc trong các bệnh phế quản cấp & mạn',
        "tag": 'Người lớn khuyên dùng',
      },
      {
        "name": 'Dung dịch súc họng sát khuẩn Betadine 1%',
        "brand": 'Mundipharma (Thụy Sĩ)',
        "price": '72.000đ',
        "unit": 'Chai 125ml',
        "iconType": 'spray',
        "desc": 'Diệt khuẩn hầu họng, ngăn ngừa nhiễm trùng thứ phát',
        "tag": 'Bác sĩ khuyên dùng',
      },
    ],
    'allergic': [
      {
        "name": 'Thuốc chống dị ứng giảm kích ứng ngứa cổ Telfast 180mg',
        "brand": 'Sanofi (Pháp)',
        "price": '90.000đ',
        "unit": 'Hộp 1 vỉ x 10 viên',
        "iconType": 'pill',
        "desc": 'Kháng histamin thế hệ mới, giảm ngứa họng và ho dị ứng',
        "tag": 'Thương hiệu Pháp',
      },
      {
        "name": 'Viên sủi tăng sức đề kháng Redoxon Double Action',
        "brand": 'Bayer (Đức)',
        "price": '75.000đ',
        "unit": 'Tuýp 10 viên',
        "iconType": 'pill',
        "desc": 'Bổ sung Vitamin C & Kẽm tăng miễn dịch đường hô hấp',
        "tag": 'Bảo vệ sức khỏe',
      },
    ],
    'irritant': [
      {
        "name": 'Viên ngậm giảm ho ngứa rát họng Strepsils Cool',
        "brand": 'Reckitt (Anh)',
        "price": '34.000đ',
        "unit": 'Hộp 2 vỉ x 12 viên',
        "iconType": 'pill',
        "desc": 'Giảm đau rát họng, giảm ho kích ứng do nhiệt độ, máy lạnh',
        "tag": 'Phổ biến',
      },
      {
        "name": 'Dung dịch xịt vệ sinh mũi họng nước muối biển sâu Xịt Spray',
        "brand": 'Pharmed (Việt Nam)',
        "price": '45.000đ',
        "unit": 'Lọ 75ml',
        "iconType": 'droplet',
        "desc": 'Rửa trôi khói bụi và các chất kích thích niêm mạc hô hấp',
        "tag": 'Khuyên dùng hàng ngày',
      },
    ],
    'whooping': [
      {
        "name": 'Siro ho bổ phế Nam Hà Chỉ Khái Lộ',
        "brand": 'Dược Nam Hà (Việt Nam)',
        "price": '32.000đ',
        "unit": 'Chai 125ml',
        "iconType": 'siro',
        "desc": 'Thảo dược trị ho lâu ngày, ho rít phế quản',
        "tag": 'Y học cổ truyền',
      },
    ]
}

_SLEEP_PRODUCTS = [
    {
      "name": 'Kẹo dẻo hỗ trợ giấc ngủ Melatonin Gummies 5mg',
      "brand": 'Natrol (Mỹ)',
      "price": '320.000đ',
      "unit": 'Hộp 90 viên',
      "iconType": 'pill',
      "desc": 'Bổ sung Melatonin tự nhiên giúp dễ ngủ, ngủ sâu giấc',
      "tag": 'Bán chạy nhất',
    },
    {
      "name": 'Gối chống ngáy thông minh định hình cao cấp',
      "brand": 'Liên Á (Việt Nam)',
      "price": '450.000đ',
      "unit": 'Cái',
      "iconType": 'droplet', 
      "desc": 'Thiết kế nâng đỡ cổ góc 15-30 độ, thông thoáng đường thở',
      "tag": 'Lời khuyên bác sĩ',
    },
    {
      "name": 'Miếng dán cánh mũi hỗ trợ thở giảm ngáy',
      "brand": 'Breathe Right (Mỹ)',
      "price": '185.000đ',
      "unit": 'Hộp 30 miếng',
      "iconType": 'spray',
      "desc": 'Mở rộng đường thở cơ học, giảm nghẹt mũi, giảm ngáy',
      "tag": 'Nhập khẩu Mỹ',
    },
]

@router.get("/cough")
def get_cough_products(category: str = 'dry', subject: str = 'adult'):
    products = _MOCK_PRODUCTS.get(category, _MOCK_PRODUCTS['dry'])
    is_pediatric = subject in ['child', 'infant']
    
    if not is_pediatric:
        return {"products": products}
        
    adapted_products = []
    for p in products:
        p_copy = dict(p)
        if 'Prospan' in p_copy['name']:
            p_copy['name'] = 'Siro ho trẻ em Prospan (Đức)'
            p_copy['tag'] = 'Khuyên dùng cho bé'
        elif 'Bảo Thanh' in p_copy['name']:
            p_copy['name'] = 'Siro bổ phế Bảo Thanh (Chai Trẻ Em)'
            p_copy['iconType'] = 'siro'
            p_copy['tag'] = 'Thảo dược dịu ngọt'
        elif 'ACC200' in p_copy['name'] or 'Telfast' in p_copy['name']:
            p_copy['desc'] = 'Sản phẩm này chủ yếu cho người lớn. Cần liên hệ Dược sĩ Long Châu để tư vấn liều dùng & thay thế thuốc siro phù hợp với trẻ nhỏ.'
            p_copy['tag'] = 'Cảnh báo'
            p_copy['isWarningCard'] = True
        adapted_products.append(p_copy)
        
    return {"products": adapted_products}

@router.get("/sleep")
def get_sleep_products():
    return {"products": _SLEEP_PRODUCTS}
