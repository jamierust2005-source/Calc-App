"""Pytest unit tests for the calculator module.

These tests exercise the four arithmetic functions exposed by
calculator.py.  To execute them locally, run ``pytest`` from the
repository root.  The Jenkins pipeline will run these tests as part
of the build.
"""

import pytest

from calculator import add, subtract, multiply, divide


def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0


def test_subtract():
    assert subtract(5, 3) == 2
    assert subtract(0, 4) == -4


def test_multiply():
    assert multiply(3, 4) == 12
    assert multiply(-2, 3) == -6


def test_divide():
    assert divide(10, 2) == 5
    assert divide(9, 3) == 3


def test_divide_by_zero(capsys):
    # When dividing by zero, the function should return None and emit an error.
    result = divide(1, 0)
    captured = capsys.readouterr()
    assert result is None
    assert "cannot divide by zero" in captured.err.lower()