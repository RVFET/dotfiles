function myip --description "Fetch public IP"
    curl -s --max-time 2 https://1.1.1.1/cdn-cgi/trace 2>/dev/null
end
