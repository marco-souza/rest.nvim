print("Starting tests...\n\n")

-- run all
local tests = {
  require("tests.rest_parser"),
  require("tests.env"),
}

for _, test_suite in ipairs(tests) do
  for name, test in pairs(test_suite) do
    local status, err = pcall(test)
    if not status then
      print(string.format("Test failed: %s\n%s", name, err))
    else
      print(string.format("Test passed: %s\n", name))
    end
  end
end
