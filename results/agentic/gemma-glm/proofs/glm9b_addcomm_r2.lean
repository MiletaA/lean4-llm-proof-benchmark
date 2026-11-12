import Mathlib

-- Define the property of commutativity as an hypothesis
variable (comm : a + b = b + a)

-- Helper lemma to prove that addition is symmetric
lemma add_symmetric [comm] : a + b = b + a := comm

-- Target theorem
theorem add_comm_test [comm] (a b : ℕ) :
  a + b = b + a := add_symmetric
