import sys

last_time = dict()

lines = list(map(lambda x: x.split(' '), sys.stdin))

def get_prev_time(ind):
    while len(ind) > 0:
        if ind in last_time:
            return last_time[ind]
        ind = ind[1:]

def clean_times(ind):
    global last_time
    last_time = {k: v for k, v in last_time.items() if len(k) <= len(ind)}

out = []
for line in reversed(lines):
    if len(line) < 2:
        out.append(line)
        continue
    try:
        ind = line[0]
        ts = float(line[1])
        prev_time = get_prev_time(ind)
        last_time[ind] = ts
        clean_times(ind)
        if prev_time is None:
            prev_time = ts
        out.append([line[0]] + [str(prev_time - ts)] + line[1:])
    except ValueError:
        out.append(line)

for l in reversed(out):
    sys.stdout.write(' '.join(l))
