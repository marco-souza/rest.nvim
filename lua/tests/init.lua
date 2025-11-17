print("Starting tests...\n\n")

-- run all
local tests = {
  require("tests.rest_parser"),
  require("tests.env"),
  require("tests.terminal"),
}

local passed = 0
local failed = 0

for _, test_suite in ipairs(tests) do
  for name, test in pairs(test_suite) do
    local status, err = pcall(test)
    if not status then
      print(string.format("Test failed: %s\n%s", name, err))
      failed = failed + 1
    else
      print(string.format("Test passed: %s", name))
      passed = passed + 1
    end
  end
end

print("\n" .. string.rep("=", 50))
print(string.format("Results: %d passed, %d failed", passed, failed))
print(string.rep("=", 50))
