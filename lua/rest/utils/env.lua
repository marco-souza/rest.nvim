local M = {}

local ENV_VAR_RE = "$([A-Za-z_]+)"

function M.replace_envs(str)
  if type(str) ~= "string" then
    error("Invalid input: str must be a string")
    return nil
  end

  local output = str
  while string.match(output, ENV_VAR_RE) do
    local env_var = string.match(output, ENV_VAR_RE)
    local env_value = os.getenv(env_var) or ""

    output = output:gsub(ENV_VAR_RE, env_value, 1)
  end

  return output
end

return M
