# -*- coding: utf-8 -*-

class Failed < StandardError
  HTTP_STATUS = 500
end

class NotOK < Failed
  HTTP_STATUS = 400   # 400 Bad Request
end

class NotLoggedIn < Failed
  HTTP_STATUS = 401   # 401 Unauthorized
end

class NotPaid < Failed
  HTTP_STATUS = 402   # 402 Payment Required
end

class NotPermitted < Failed
  HTTP_STATUS = 403   # 403 Forbidden
end

class NotExist < Failed
  HTTP_STATUS = 404   # 404 Not Found
end

class NotValid < Failed
  HTTP_STATUS = 422   # 422 Unprocessable Entity
end
