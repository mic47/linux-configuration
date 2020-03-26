import sys

token = sys.argv[1]
pwd = sys.argv[2]
pwd2 = sys.argv[2] + " -> "

order= [[], [], []]
for line in sys.stdin:
    try:
        with_token, _, _, _, directory, command = line.split(",", maxsplit=5)
        _, hist_token = line.rsplit(" ", maxsplit=1)
        if hist_token == token:
            order[2].append(command)
        elif directory == pwd or (directory.startswith(pwd2)):
            order[1].append(command)
        else:
            order[0].append(command)
    except ValueError:
        pass

for x in order:
    for y in x:
        sys.stdout.write(y)


