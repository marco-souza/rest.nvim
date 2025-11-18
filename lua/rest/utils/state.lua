local M = {}

---@type Request|nil
local current_request = nil

---@type Response|nil
local current_response = nil

---@type boolean
local is_loading = false

---@type string|nil
local error_message = nil

---@type function[]
local listeners = {}

---Register a listener callback for state changes
---@param callback function Callback function(state_key, new_value, old_value)
local function subscribe(callback)
  table.insert(listeners, callback)
end

---Notify all listeners of a state change
---@param key string State key that changed
---@param new_value any New value
---@param old_value any Previous value
local function notify(key, new_value, old_value)
  for _, callback in ipairs(listeners) do
    callback(key, new_value, old_value)
  end
end

---Set the current request
---@param request Request|nil
function M.set_request(request)
  local old = current_request
  current_request = request
  notify("request", request, old)
end

---Get the current request
---@return Request|nil
function M.get_request()
  return current_request
end

---Set the current response
---@param response Response|nil
function M.set_response(response)
  local old = current_response
  current_response = response
  notify("response", response, old)
end

---Get the current response
---@return Response|nil
function M.get_response()
  return current_response
end

---Set loading state
---@param loading boolean
function M.set_loading(loading)
  local old = is_loading
  is_loading = loading
  notify("loading", loading, old)
end

---Get loading state
---@return boolean
function M.is_loading()
  return is_loading
end

---Set error message
---@param error string|nil
function M.set_error(error)
  local old = error_message
  error_message = error
  notify("error", error, old)
end

---Get error message
---@return string|nil
function M.get_error()
  return error_message
end

---Get all state
---@return table
function M.get_all()
  return {
    request = current_request,
    response = current_response,
    is_loading = is_loading,
    error = error_message,
  }
end

---Reset all state
function M.reset()
  current_request = nil
  current_response = nil
  is_loading = false
  error_message = nil
  notify("reset", {}, nil)
end

---Subscribe to state changes
M.subscribe = subscribe

return M
