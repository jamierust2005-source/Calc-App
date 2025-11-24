"""
A simple calculator script that supports basic arithmetic operations.

Usage:
    python calculator.py --operation <add|subtract|multiply|divide> <number1> <number2>

Example:
    python calculator.py --operation add 4 5

This script accepts two numeric arguments and an operation type.  It will print
the result of the requested operation to standard output.  When dividing, the
script checks for division by zero and emits an error message instead of
raising an exception.
"""

import argparse
import sys


def add(a: float, b: float) -> float:
    """Return the sum of two numbers."""
    return a + b


def subtract(a: float, b: float) -> float:
    """Return the difference of two numbers."""
    return a - b


def multiply(a: float, b: float) -> float:
    """Return the product of two numbers."""
    return a * b


def divide(a: float, b: float) -> float:
    """Return the quotient of two numbers.  If the divisor is zero, return None."""
    if b == 0:
        print("Error: cannot divide by zero", file=sys.stderr)
        return None
    return a / b

#test

def main() -> None:
    parser = argparse.ArgumentParser(description="Simple command‑line calculator")
    parser.add_argument(
        "--operation",
        choices=["add", "subtract", "multiply", "divide"],
        required=True,
        help="The arithmetic operation to perform",
    )
    parser.add_argument(
        "a", type=float, help="First operand (numeric)"
    )
    parser.add_argument(
        "b", type=float, help="Second operand (numeric)"
    )
    args = parser.parse_args()

    operations = {
        "add": add,
        "subtract": subtract,
        "multiply": multiply,
        "divide": divide,
    }

    func = operations[args.operation]
    result = func(args.a, args.b)
    if result is not None:
        print(result)


if __name__ == "__main__":
    main()