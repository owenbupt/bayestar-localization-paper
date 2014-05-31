import numpy as np
from matplotlib import pyplot as plt
import scipy.integrate
import scipy.special

fig = plt.figure(figsize=(3.5, 2.5))
ax = fig.add_subplot(111)

np.random.seed(0)
nruns = 10
neval = np.unique(np.round(np.logspace(0, 2, 50)).astype(int))

def integrand(x, a, b, c, d, e, f):
    I0arg = np.sqrt(np.square(c * np.cos(x) + d * np.sin(x)) + np.square(e * np.cos(x) + f * np.sin(x)))
    return np.exp(a * np.cos(x) + b * np.sin(x) + I0arg) * scipy.special.i0e(I0arg)

def periodic_quad(func, args, n):
    return 2*np.pi/n * np.sum(func(2*np.pi/n * np.arange(n), *args))

for irun in range(nruns):
    args = tuple(np.random.randn(6).tolist())
    exact, _ = scipy.integrate.quad(
        integrand, 0, 2*np.pi, args, epsabs=1e-14, epsrel=1e-14, limit=200)
    approx = np.asarray([
        periodic_quad(integrand, args, n) for n in neval])
    relerr = np.abs(approx - exact) / exact
    ax.plot(neval, relerr, '-k')

def integrand(x, a, b, c, d, e, f, g, h, i, j):
    I0arg1 = np.sqrt(np.square(c * np.cos(x) + d * np.sin(x)) + np.square(e * np.cos(x) + f * np.sin(x)))
    I0arg2 = np.sqrt(np.square(g * np.cos(x) + h * np.sin(x)) + np.square(i * np.cos(x) + j * np.sin(x)))
    return np.exp(a * np.cos(x) + b * np.sin(x) + I0arg1 + I0arg2) * scipy.special.i0e(I0arg1) * scipy.special.i0e(I0arg2)

for irun in range(nruns):
    args = tuple(np.random.randn(10).tolist())
    exact, _ = scipy.integrate.quad(
        integrand, -1, 1, args, epsabs=1e-14, epsrel=1e-14, limit=200)
    approx = np.asarray([
        scipy.integrate.fixed_quad(integrand, -1, 1, args, n)[0] for n in neval])
    relerr = np.abs(approx - exact) / exact
    ax.plot(neval, relerr, '--k')

ax.set_xscale('log')
ax.set_yscale('log')
ax.set_ylim(1e-16, 1)
ax.set_xlabel('number of function evaluations')
ax.set_ylabel('relative error')

fig.subplots_adjust(left=0.175, bottom=0.15, right=0.95, top=0.95)

fig.savefig('polarization_angle_integral_convergence.pdf')