json.status @status

if @status == 200
  json.message "User authenticated successfully."
  json.access_token @access_token
else
  json.error_message @error_message
end

json.ignore_nil!
