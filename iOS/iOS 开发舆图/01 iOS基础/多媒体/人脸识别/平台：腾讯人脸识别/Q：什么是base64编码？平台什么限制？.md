A：base64编码是一种基于64个可打印字符对二进制数据进行编码存储的方式，方便在HTTP请求/响应正文中以明文字符串形式传输图片、语音等类型数据（二进制数据）。

base64编码存在多个变种实现，请开发者注意以下细节。

编码结果只会包含大小写字母、数字、+、/共64种可打印字符，不会包含回车、换行等特殊控制字符
