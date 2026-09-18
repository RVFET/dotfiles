function jsonize --description "Format and repair JSON input using rich and json_repair"
    if test (count $argv) -gt 0
        python3 -c "import sys, rich, json_repair; rich.print_json(data=json_repair.loads(sys.argv[1]))" "$argv[1]"
    else
        python3 -c "import sys, rich, json_repair; rich.print_json(data=json_repair.loads(sys.stdin.read()))"
    end
end
