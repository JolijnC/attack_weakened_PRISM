'''
This script is a companion to the paper An analysis of a weakened version of PRISM.
It is used to compute the complexity estimates for the attack in the (Q)ROM of a weak version of PRISM.
It outputs the results of all three tables in Section 5 of the paper, and the parameters considered can be modified on lines 67, 109, and 141.
'''

def pseudoprime_cost_computation_Fermat(X: int, b: int) -> float:
    """Given the number X = 2^a and b (bound) output probability we hash into a Fermat-2 pseudoprime"""
    L = exp(ln(X)*ln(ln(ln(X))) /ln(ln(X)))
    if b == 'l':
        return L^(-1/2)
    elif b == 'c':
        return L^(-1)
    
def pseudoprime_cost_computation_MR(a: int, t: int) -> float:
    """Given a (number of bits) and t (number of iterations) output probability we hash into a strong pseudoprime"""
    if t == 1:
        return a^2 * 4^(2-sqrt(a))
    elif t < a/9:
        return a^(3/2)*2^t * t^(-1/2)* 4^(2-sqrt(t*a))
    else: 
        return 7/20 * a * 2^(-5 * t) + 1/7 * a^(15/4) * 2^(-a/2 - 2*t) + 12*a * 2^(-a/4 -3*t)

def factoring_cost_computation(X: int) -> float:
    """For given X = 2^a give the minimum of cost for the two factoring algorithms"""
    quadratic_sieve_cost = exp((ln(X)*ln(ln(X)))^(1/2))
    general_number_field_sieve_cost = exp((64/9 * ln(X))^(1/3)*ln(ln(X))^(2/3))
    return min(quadratic_sieve_cost, general_number_field_sieve_cost)

def total_cost_computation_Fermat(X: int, B: int, b: str) -> int:
    """Given X = 2^a, a prospective smoothness bound B and a side b, return the total complexity in log_2 """
    cost_factoring = factoring_cost_computation(X)

    cost_smooth = dickman_rho(ln(X)/ln(B))

    cost_pseudoprime = pseudoprime_cost_computation_Fermat(X, b)

    total = cost_factoring*2 * (1/cost_smooth)^2 * 1/cost_pseudoprime + B^2

    return ceil(log(total,2)) 

def total_cost_computation_MR(X: int, a: int, B: int, t: int) -> int:
    """Given X = 2^a, a prospective smoothness bound B and a prospective number of iterations t, return the total complexity in log_2 """
    cost_factoring = factoring_cost_computation(X)

    cost_smooth = dickman_rho(ln(X)/ln(B))

    cost_pseudoprime = pseudoprime_cost_computation_MR(a, t)

    total = cost_factoring*2 * (1/cost_smooth)^2 * 1/cost_pseudoprime + B^2

    return ceil(log(total,2)) 

def total_cost_computation_MR_quantum(X: int, a: int, B: int, t: int) -> int:
    """Given X = 2^a, a prospective smoothness bound B and a prospective number of iterations t, return the total complexity in log_2 """
    cost_factoring = a^2

    cost_smooth = dickman_rho(ln(X)/ln(B))

    cost_pseudoprime = pseudoprime_cost_computation_MR(a, t)

    total = cost_factoring*2 * (1/cost_smooth)^2 * 1/cost_pseudoprime + B^2

    return ceil(log(total,2)) 


list_a = [248, 192, 376, 256, 500, 320] #Change this for different bounds

#This code gives the result for Table 1, the probability to hash into a pseudoprime. 
print('Table 1')

for a in list_a:
    X = 2^a
    print(a)
    print('conjectured lower bound for P_pp')
    print(float(log(pseudoprime_cost_computation_Fermat(X, 'c'),2)))

    print('upper bound for P_pp')
    print(float(log(pseudoprime_cost_computation_Fermat(X, 'l'),2)))

    print(80* '-')


#This gives the results of Table 2, the total complexity for the Fermat_2 prime
print('Table 2')

for b in ['l', 'c']:
    print(b)
    for a in list_a:
        print('a = ' + str(a))
        X = 2^a
        costs = []
        B = 1
        while B < 2^128:
            B *= 2
            costs.append(total_cost_computation_Fermat(X, B, b))



        minimum = min(costs)
        print(minimum, costs.index(minimum))
        print(80 * "=")

print(80 * '-')

#This gives the result in a dictionary 'a: [cost, B, t]' for each of the list_a 
print("Table 3")

bounds = [128, 128, 192, 192, 256, 256]
all_found = [False]*len(list_a)

results = {}
for a in list_a:
    results[a] = []

t = 1

while not all(all_found):
    print(t)
    for index, a in enumerate(list_a):
        if not all_found[index]:
            X = 2^a
            costs = []
            B = 1
            while B < 2^128:
                B *= 2
                costs.append(total_cost_computation_MR(X, a, B, t))

            minimum = min(costs)


            if minimum >= bounds[index]:
                all_found[index] = True
                results[a] = minimum, costs.index(minimum), t
    t += 1
print(results)

#This gives the result in a dictionary 'a: [cost, B, t]' for each of the list_a, with quantum factoring costs 
print("Table 4")

bounds = [128, 128, 192, 192, 256, 256]
all_found = [False]*len(list_a)

results = {}
for a in list_a:
    results[a] = []

t = 1

while not all(all_found):
    print(t)
    for index, a in enumerate(list_a):
        if not all_found[index]:
            X = 2^a
            costs = []
            B = 1
            while B < 2^128:
                B *= 2
                costs.append(total_cost_computation_MR_quantum(X, a, B, t))

            minimum = min(costs)


            if minimum >= bounds[index]:
                all_found[index] = True
                results[a] = minimum, costs.index(minimum), t
    t += 1

print(results)