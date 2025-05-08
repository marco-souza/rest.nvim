local replace_envs = require("utils.env").replace_envs

local tests = {
  replace_envs_no_env = function()
    local env_str = "no-env-to-replace"
    local output = replace_envs(env_str)

    assert(
      output == env_str,
      string.format("Expected '%s', got '%s'", env_str, output)
    )
  end,

  replace_envs_one_env = function()
    local env_str = "hello $USER"
    local env_value = vim.fn.getenv("USER")
    local output = replace_envs(env_str)

    assert(
      output == "hello " .. env_value,
      string.format("Expected 'hello world', got '%s'", output)
    )
  end,

  replace_envs_multiple_envs = function()
    local env_str = "hello $USER, your home is $HOME"
    local env_value_user = vim.fn.getenv("USER")
    local env_value_home = vim.fn.getenv("HOME")
    local output = replace_envs(env_str)

    assert(
      output
        == "hello " .. env_value_user .. ", your home is " .. env_value_home,
      string.format("Expected 'hello world', got '%s'", output)
    )
  end,
}

return tests
