import math

f1 = 50
f2 = 100
dur = 5
points = 1000000

with open("rise_angles.txt", "w") as f:
    output = []
    for i in range(points):
        t = dur * i / points
        output.append(math.pow(t, 360 * (f1 - f2) / dur) + 360 * f1 * t)