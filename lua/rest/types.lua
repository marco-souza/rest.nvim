---@class Request
---@field method string HTTP method (GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD)
---@field url string Request URL
---@field headers table<string, string> Request headers
---@field body string|nil Request body (for POST, PUT, PATCH)

---@class Response
---@field status number HTTP status code
---@field body string Response body
---@field headers table<string, string> Response headers
---@field error string|nil Error message if request failed

---@class DashboardOptions
---@field margin number|nil Margin around dashboard (default: 0)
---@field width number|string|nil Dashboard width (default: "80%")
---@field height number|string|nil Dashboard height (default: "80%")
---@field border string|nil Border style (default: "single" for request, "double" for response)
---@field content string[]|nil Pre-loaded request content
---@field request_size string|number|nil Request pane size (default: "30%")
---@field response_size string|number|nil Response pane size (default: "70%")

---@class RestConfig
---@field margin number Margin around dashboard (default: 2)
---@field width number|string Dashboard width (default: "80%")
---@field height number|string Dashboard height (default: "80%")
---@field border string Border style (default: "rounded")
---@field request_size string|number Request pane size (default: "30%")
---@field response_size string|number Response pane size (default: "70%")

---@class LoaderConfig
---@field frames string[] Spinner frames for animation
---@field interval number Interval between frames in ms (default: 100)
---@field show_notification boolean Show notification when done (default: false)

return {}
