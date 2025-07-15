def bad_function():
    if True:
        if True:
            if True:
                print("Too many nested ifs")
                if True:
                    return "deeply nested"
    return None

def missing_error_handling():
    # This should have try/catch
    result = 10 / 0
    return result

def inefficient_loop():
    # O(n^2) when it could be O(n)
    items = []
    for i in range(1000):
        for j in range(1000):
            if i == j:
                items.append(i)
    return items