def bad_function():
    if True:
        if True:
            if True:
                print("Too many nested ifs")
    return None

# Missing error handling
def risky_function():
    result = 10 / 0
    return result

# Performance issue
def slow_function():
    items = []
    for i in range(1000):
        for j in range(1000):
            items.append(i * j)
    return items
