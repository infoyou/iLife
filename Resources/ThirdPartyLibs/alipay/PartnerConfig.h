//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//"Partner": "2088701598244705",    //  ID
//"SellerAccountName": "account@jitmarketing.cn",    // 账号

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088701598244705"
//收款支付宝账号
#define SellerID  @"account@jitmarketing.cn"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @""

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALEtRLU0wUHcmn8seP8Du8P6jBe57/igqtqwKoPU8t6Zxr/U8pNB+ORj4uTLblvT+KdYCR1TIbkvaZWkHaD/dlcVw+xM8dWqvM86Hf+NB7y7st1mzN9xVhkVwr3sc/2B4J3jOQMpEkN19yejf3KCo779zYdldWi6Kk9hpQeYYNqdAgMBAAECgYEAhsoLlVe3FqX/m3R38HokpKm9XmeEWr/Qe2K+VWDyC8stWs9kZAcylH4xJSJmqNGQP69H79lItJuPVdpu+AahPccs+DBt/moUCdsP5IZphk4gNVTJDPxzqO2mPiGJH+gjK0u/DhiOQUKUcOMjTgEkE+U5d0ftjVxm+WT5WiLS3AECQQDXky9sJmgQ2fU+iYnuGTQDs8NXghUgdwd6RjyTf1lOjlBMnZEUhdtDJ4tQe9X9CjgHwrZXF7iOlRV0mIt7FZQdAkEA0mbBwlCYJVluDFSJORzdZmpllZcfRncjQ3vepNvdYgppXJhLNqaLAbSTHXBbIsTTsiVUOi4ipA8crf4FJ9CYgQJAQlVR9E9lGjpXEmU0AgXTUYhRBW5Lne/CZ0eRgDlhe6Ci6NBbQhtmOqXCYoOYdwJb91dc0DPGYGlTbss5sCgVqQJALGWceylQgYkWbKml7xRFL6hB2UfzRIY9Pa80surmExsJUo2cSWLpMCnvZSXhRTvtQ8kWtdQoYSADOD/CzLz6gQJAKixONE4XyXercbnLKUXcMZ6NKpEaoS5eaTAkyzpHMxWmNV1S5k1pViKq8wMhY/GarOEIOEcTbEtYv32zeOvHpw=="

//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCidRWLiJfzFuKYNYyoW27s70e9yStuiE1Et4aQ qUGL4Z4/vG6p8sJ3JALUTQwZmHwY7GeTqA+n2nUSqpFQLfqUeTBS5IDnxR+5DqL5lOaCDDDw3Uxn CnBdBcfuiwjsEXaDv4sqi/So6tmQlVgi9wFlRc87uM6/kL+WxkhkenIgMwIDAQAB"

#endif
