local parse_rest_file = require("utils.rest_parser").parse_rest_file

local tests = {
  parse_valid_rest = function()
    local testContent = [[
      GET https://example.com/api/resource

      Accept: application/json
      Content-Type: application/json

      {"key": "value"}
    ]]

    local res = parse_rest_file(testContent)

    assert(res ~= nil, "Parsing failed: result is nil")
    assert(res.headers["Accept"] ~= nil, "Parsing failed: Accept header is nil")
    assert(
      res.headers["Content-Type"] ~= nil,
      "Parsing failed: Content-Type header is nil"
    )
    assert(res.body ~= nil, "Parsing failed: result.body is nil")
    assert(
      res.body == '{"key": "value"}',
      "Parsing failed: result.body is not correct"
    )
  end,

  parse_valid_rest_with_multiline_body = function()
    local testContent = [[
      GET https://example.com/api/resource

      Accept: application/json
      Content-Type: application/json

      {
        "key": "value",
        "key2": "value",
        "key22": "value"
      }
    ]]

    local res = parse_rest_file(testContent)

    assert(res ~= nil, "Parsing failed: result is nil")
    assert(res.headers["Accept"] ~= nil, "Parsing failed: Accept header is nil")
    assert(
      res.headers["Content-Type"] ~= nil,
      "Parsing failed: Content-Type header is nil"
    )
    assert(res.body ~= nil, "Parsing failed: result.body is nil")

    -- parse body
    local body = vim.json.decode(res.body)
    assert(
      body.key == "value",
      "Parsing failed: result.body.key is not correct"
    )
    assert(
      body.key2 == "value",
      "Parsing failed: result.body.key2 is not correct"
    )
    assert(
      body.key22 == "value",
      "Parsing failed: result.body.key22 is not correct"
    )
  end,

  parse_valid_rest_wo_body = function()
    local testContent = [[
      GET https://example.com/api/resource

      Accept: application/json
      Content-Type: application/json

    ]]

    local res = parse_rest_file(testContent)

    assert(res ~= nil, "Parsing failed: result is nil")
    assert(res.body == nil, "Parsing failed: result.body is not nil")
    assert(res.headers["Accept"] ~= nil, "Parsing failed: Accept header is nil")
    assert(
      res.headers["Content-Type"] ~= nil,
      "Parsing failed: Content-Type header is nil"
    )
  end,

  parse_valid_rest_wo_header = function()
    local testContent = [[
      GET https://example.com/api/resource


    ]]

    local res = parse_rest_file(testContent)

    assert(res ~= nil, "Parsing failed: result is nil")
    assert(res.body == nil, "Parsing failed: result.body is not nil")
    assert(next(res.headers) == nil, "Parsing failed: header is not nil")
  end,

  fetched_parsed_request = function()
    local testContent = [[
      GET https://postman-echo.com/get

      Accept: application/json
      Content-Type: application/json

      {"key": "value"}
    ]]

    local request = parse_rest_file(testContent)
    assert(request ~= nil, "Parsing failed: result is nil")

    local curl = require("plenary.curl")
    local res = curl.request({
      url = request.url,
      method = request.method,
      headers = request.headers,
      body = request.body,
    })

    assert(res.status == 200, "Request failed: " .. res.status)
    assert(type(res.body) == "string", "Request failed: " .. res.status)

    local data = vim.json.decode(res.body)
    assert(
      data.args.key == "value",
      "Parsing failed: result.body.key is not correct"
    )
  end,
}

-- run all

for name, test in pairs(tests) do
  local status, err = pcall(test)
  if not status then
    print(string.format("Test failed: %s\n%s", name, err))
  else
    print(string.format("Test passed: %s\n", name))
  end
end
