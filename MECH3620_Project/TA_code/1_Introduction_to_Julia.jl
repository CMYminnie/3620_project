### A Pluto.jl notebook ###
# v0.20.24

#> [frontmatter]
#> title = "Using Julia"
#> layout = "layout.jlhtml"
#> tags = ["welcome"]
#> description = ""

using Markdown
using InteractiveUtils

# ╔═╡ f2953cd1-dcf6-4286-be57-6f096ebc7a44
using LinearAlgebra  # For performing linear algebra operations

# ╔═╡ ee5d60d0-5f0e-11eb-0574-6553f2bad5a5
# Table of Contents
begin
	using PlutoUI
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));
	alert(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Alert!", [text]));
	exercise(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("correct", "Exercise", [text]));
	correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]));
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));
	TableOfContents()
end

# ╔═╡ d0e4dac0-5edb-11eb-0312-678a24ad0573
md"""
# Introduction to Julia
"""

# ╔═╡ 0f4bdbc0-5eea-11eb-35c3-d13c5d187b11
html"""
<center><img src=https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/b5551ca7946b4a25746c045c15fbb8806610f8d0/images/julia-logo-color.svg></center>
"""

# ╔═╡ 5f6f01f0-5eee-11eb-090f-07ee55921d29
md"""
>## Today's key things to learn
>1. How to navigate stuff in `Pluto.jl`?
>2. Variables and Printing
>3. Data structures
>4. Control flow
>5. Linear algebra
"""

# ╔═╡ 96a0f5c8-0c73-47c4-abef-2013ce844142
md"---
## How to navigate stuff in `Pluto.jl`?
"

# ╔═╡ 9954bd5e-db1a-4ec1-985f-86705a02f218
md"
### List of shortcuts
1. **Shift+Enter**: run cell
2. **Ctrl+Enter**: add cell below
3. **Cmd+Enter**: run cell and add cell below
4. **Delete** or **Backspace**: delete empty cell
5. **fn+Up**: select cell above
6. **fn+Down**: select cell below
7. **Cmd+Q**: interrupt notebook
8. **Cmd+S**: submit all changes
9. **Cmd+C**: copy selected cells
10. **Cmd+X**: cut selected cells
11. **Cmd+V**: paste selected cells
"

# ╔═╡ 7555b9fc-ced2-475b-9580-aeb3d5f360fd
println("Let's try writing in Pluto.jl");

# ╔═╡ 36b2d1e8-43cb-492e-8c45-d89381919403


# ╔═╡ 71a6ced3-73f0-470c-a08a-2f4362e5f5e0


# ╔═╡ f0111d90-5f09-11eb-3977-237d140094d2
md"---
## 1. Variables, Printing, and Blocks
"

# ╔═╡ 4b5e3410-60c9-11eb-1874-f94b8c084017
md"""
### 1a. Assigning a value to a variable
Julia supports numbers and string types that would be useful to any mathematician, physicist, or engineer, such as real and complex numbers."""

# ╔═╡ 5ca1f2f5-64ee-4d6b-96bc-42a5bb63ba07
# ╠═╡ disabled = true
#=╠═╡
# Define "integer" number
Z = 2
  ╠═╡ =#

# ╔═╡ 2509e0b0-5f0d-11eb-0b86-ef2bfdc59221
# Define "real" number
a = 1.5

# ╔═╡ f2b0d720-60a8-11eb-10b6-cd9caa5fa211
# Define "complex" number
z = 0.5 + 3im

# ╔═╡ 0d779460-60c0-11eb-2832-01d2249a84d4
cha = 'a'

# ╔═╡ fb879b7e-60a9-11eb-02ed-17dcdc4f6e13
name = "Arararagi"

# ╔═╡ c64cde23-4fb1-4879-9cf3-008eb56029b4
char1 = "a"

# ╔═╡ 12329650-60be-11eb-271e-1b4de0529ecb
md"You can check the type of a variable by calling `typeof()` on it. Try it out!"

# ╔═╡ 8dc81ef9-43e4-4762-b737-c975b5073b1e
typeof(char1)

# ╔═╡ bc20e4fb-bdfd-4a94-a1a8-dd7f04a7d70f
md"
### 1b. Printing methods
!!! tip
	The function `println()` or the `@show` macro will also display the output in a Pluto notebook. Learn the difference!
"

# ╔═╡ 4764baac-63e0-4aa7-b811-44ed72178709
println(z)

# ╔═╡ 757f0cbb-5ac5-4fa0-a811-69f8e3b8a494
@show z

# ╔═╡ a1dc2650-60c7-11eb-05f3-27d797041b10
md"
### 1c. Block types
Pluto notebooks accept only two types of expressions: either **single-line blocks**, or **code-blocks** wrapped in ```begin ... end```. In case of the latter, it returns the value of the last line of the code-block."

# ╔═╡ cb5bedd0-60c7-11eb-3f23-b73a12244a5c
# Sum complex numbers
r = a + z

# ╔═╡ f200cff0-60c7-11eb-38b8-21dbfc93d7a5
# Evaluate product of complex numbers
r^2

# ╔═╡ ac9b2c55-82ff-41b3-94f9-07123f577200
begin
	p = r^2 # Square complex number 'r'
	s = 2 * p # Double complex number 'p' (SHOWS THE OUTPUT OF THIS LAST LINE)
end

# ╔═╡ 0edc6e3b-5f1c-4ef5-837f-8c8843e82cca
md"""
!!! tip

	Use the **Live docs** feature at the bottom right to view documentation!
"""

# ╔═╡ 7395af00-60c7-11eb-0961-7704feee1971
md"""
---
## 2. Data structures
Three types of data structures are covered here: Arrays, Tuples, and Dictionaries.

**Key points:**
* Arrays and Tuples are *ordered*, while Dictionaries are *unordered*.
* Arrays are *mutable*, while Tuples are *immutable*.
"""

# ╔═╡ 76494920-5f0d-11eb-040e-63b283f2f031
md"
### 2a. Arrays
Arrays are collections of elements which are stored in memory for 'instant' access. These are useful for performing iterative processes and collecting data for operations.
"

# ╔═╡ a3f4b6f0-5f23-11eb-09ba-0bed5674f6a9
md"1D array:"

# ╔═╡ 7cc1eeb0-5f0d-11eb-39c6-2715c40576b0
# Assign array of integers to variable 'xs'
xs = [ 5, 3, 4, 1, 7 ]

# ╔═╡ 567e1d90-60a8-11eb-0962-8dda3d9e9ee1
md"You can access elements of arrays by their indices shown in the following. Note that Julia follows the `1`-convention, like MATLAB."

# ╔═╡ 2fcdc9c0-60a8-11eb-0ccf-f3306ae99262
xs[1] # Access third element of 'xs' by indexing

# ╔═╡ 58a1bab0-60c5-11eb-0e62-13f4ac387d78
md"You can access the last element of an array by entering `end`."

# ╔═╡ 3a890590-60a9-11eb-11ab-f7401ed79d5e
xs[end] # Access last element of 'xs'

# ╔═╡ a88d2ad0-5f23-11eb-2e9b-45a2858e2db3
md"2D array:"

# ╔═╡ ac1c9320-5f23-11eb-1e76-cdcbc766ecec
ys = [ 1. 5. 6.; # 2D array defined by separating rows new lines with no commas 
	   3  7  2 ] # (optionally insert colons) 

# ╔═╡ 03b3a84e-60a8-11eb-03f1-9fcfda939baf
md" In Julia, all arrays are contiguously stored in memory in column-major order, and any arrangement is just superficial. The following two evaluations are exactly the same:" 

# ╔═╡ 39252540-60a8-11eb-15d8-29d96ef90ab9
ys[1,3] # Access 1st row, 3rd column entry of 'ys'

# ╔═╡ 428b4dd0-60a8-11eb-37c7-b7a0e89073bb
ys[5] # Access the same entry via the linear index.

# ╔═╡ e53b73a0-60c3-11eb-2248-e9d103a0f756
md"So you can flatten an array into a 1D array with the following syntax:"

# ╔═╡ f7402f00-60c3-11eb-385c-a51fa5470d44
ys[:] # Flatten 'ys' into a one-dimensional array

# ╔═╡ c4ea57b0-60c8-11eb-378a-1909c829443b
md"You can evaluate the length of an array by calling a _function_, which takes an input of some type and returns some output. In this case, the function is called `length()`, and is used as follows:"

# ╔═╡ e92a95e0-60c8-11eb-0d12-530d3a0b7e43
size(ys)

# ╔═╡ 11cb4800-60c9-11eb-23f8-bb51ae2aa733
hint(md"Try `length(ys)`. The answer may not be what you expect! If so, try `size(ys)`!")

# ╔═╡ 467059e0-5f2c-11eb-3d82-ed166a16040c
md"You can also transpose arrays of `Real` numbers by attaching `'` at the end of the array."

# ╔═╡ 50c32c60-5f2c-11eb-1130-2f9ceb28caea
ys' # Transpose 'ys' from (2,3) matrix into (3,2) matrix 

# ╔═╡ 09aae9c0-5fb4-11eb-2897-2dabe0b66efd
md"

!!! note 

	Notice the different types mentioned above, e.g. `LinearAlgebra.Adjoint`. For `Complex` numbers, this would take the complex conjugates of the entries and transpose them, which is the definition of the adjoint in matrix algebra over complex numbers. We will discuss type systems shortly.
"

# ╔═╡ 86ca9e10-60a8-11eb-2875-1ba8d4efbfcc
# Define matrix of complex numbers 'zs'
zs = [ 1 + 2im    3 - 5im ;
	   6 - 4im    4 - 8im 
	   2 + 3im    3 + 9im ]

# ╔═╡ b2ba5422-60a8-11eb-1492-9be6c3d59ce6
zs' # Transpose 'zs' similarly, but signs of the imaginary component are flipped.

# ╔═╡ 67088100-438a-4e24-9753-ca16baa8fb1d
md"#### Mutation"

# ╔═╡ 009c6385-e751-4ed1-ae62-e61541f960c0
md"""
You can also modify elements of arrays (called _mutation_). It is best to do any assignments to elements of arrays within the same block that defines the array to avoid confusion.
"""

# ╔═╡ d3f781d4-4762-4ef3-b795-94a88c31088f
begin 
	ks = zeros(9) # Define array
	ks[1] = 6.0 # Assign to first element of ys
	ks[3] = 9.0 # Assign to third element of ys
end

# ╔═╡ b2370549-9ceb-4936-9079-4aef964e9bc3
ks

# ╔═╡ 7fee99c9-c130-4c20-aa41-eb8803d1ae94
md"The `push!` function appends elements to the end of a previously defined array. This operation should also be performed in the same block that defines the array."

# ╔═╡ 4d130026-e7bf-4cc9-8192-3e4f9577b2f6
begin
    xxs = [5.0, 3.0] # Define array
	push!(xxs, 6.0, 7.0, 10.0) # Append elements to the end of xs
end

# ╔═╡ 6690c260-60a7-11eb-2559-e5ec21410cd4
md"""#### Ranges

Julia has syntactic sugar for common operations, such as evenly distributed ranges.
"""

# ╔═╡ 83899950-60a7-11eb-03c5-d5cf350d1de4
# Define a range of integers from 1 to 10
ms = 1:10

# ╔═╡ 891ac50e-60a7-11eb-02d7-91282f4149a5
md"You can convert these ranges into arrays by calling the function `collect()` on them."

# ╔═╡ 9bad4180-60a7-11eb-2129-b3b0e862f96a
collect(ms) # View elements individually by providing 'ms' as an input to 'collect'.

# ╔═╡ c30c72f2-60a7-11eb-20e0-23c12131e174
md"You can also call the `range(start, stop, length = n)` function to obtain a list of ``n`` equally spaced values between `start` and `stop`."

# ╔═╡ b8cc1700-60a7-11eb-178b-6b8abb196263
# Define equally spaced values between 0 and 1
ns = range(0, 1, length = 15)

# ╔═╡ 12c88f5e-60ab-11eb-36dd-5b296dabb6d1
collect(ns)

# ╔═╡ f2655c82-66ca-11eb-2cd6-512d918b9927
md"
### 2b. Tuples
Tuples are containers of values of different types. ."

# ╔═╡ f7d47e82-66ca-11eb-2ff3-139f7d803ed6
# Define a tuple as a container of elements of various types.
tup = (1, 'a', 3.)

# ╔═╡ 01cfada8-66cb-11eb-2b97-69bb1a871daf
typeof(tup)

# ╔═╡ 0cc270d0-66cb-11eb-0471-db83d591c97c
md"Tuples share the same syntax as arrays for accessing the values at different indices."

# ╔═╡ 14eadf64-66cb-11eb-322b-194421bff2d2
tup[2]

# ╔═╡ f6060b08-91d6-4114-ba43-fa6ea9a6dea7
md"The important difference between tuples and arrays is that tuples are immutable, _i.e. their values cannot be changed._"

# ╔═╡ f2d9442b-72fa-49e2-b45d-2a352a29f247
# tup[1] = 3  # Fails because tuple entries cannot be mutated

# ╔═╡ ae36d338-aa6e-413e-bc2b-4fcbe82d4e1f
md"
### 3b. Dictionaries
If we have data sets related to one another, we may store that data in a dictionary. A good example is a contact list, where we associate names with phone numbers.
"

# ╔═╡ 867ebaba-2946-4d74-a470-e44745525eec
myphonebook = Dict("Alfi" => "123-456", "Reyner" => "654-321")

# ╔═╡ 3e89eaa5-6314-4b13-8723-b14928a8a104
md"
We can add another entry to this dictionary as follows:
"

# ╔═╡ 5f88f1b6-22b6-47c4-b9d0-40b13b751037
myphonebook["James"] = "234-567"

# ╔═╡ 1adef350-0566-4e9f-9aec-d7302c0cff23
md"
We can also get Alfi's number, and simultaneously delete him from our contact list - by using **`pop!**`
"

# ╔═╡ 8639b614-d32d-4b18-8200-abf10d14ceae
pop!(myphonebook, "Alfi")

# ╔═╡ ac1b7567-950f-4b3a-ac8e-ff32c4206adb
myphonebook

# ╔═╡ 4f4bda86-d036-4146-8f7a-2d978aee659b
md"
Unlike Tuples and Arrays, Dictionaries are not ordered. So, we can't index into them.
"

# ╔═╡ a466d409-62ee-4153-8f9e-2ce3894ee715
# myphonebook[1] # this will throw an error, since dictionaries cannot be indexed

# ╔═╡ 9d208207-be4e-49e8-bb9f-d5a66937c2f7
md"""
---
## 3. Control flow
"""

# ╔═╡ ed0d2c60-5f09-11eb-3346-73bcb62dc713
md"
### 3a. Conditionals
Standard Boolean expressions and evaluations are almost a necessity."

# ╔═╡ 3e238902-5f0a-11eb-27e9-61eb774d3620
# Assign 'true' value to variable 'lisa'. Try changing it to 'false' and observe the outputs below.
lisa = true

# ╔═╡ 5114d4ec-9ad5-4a51-aee5-435d898b36eb
md"The opposite of `true` is `false`, which is performed by prepending `!` to the variable."

# ╔═╡ 5a7de8bb-be80-4fc5-a676-d0d2da3edc5e
!lisa # Prepend ! to 'lisa' invert the value

# ╔═╡ 2309d252-5f0a-11eb-3db5-d16147bb8329
# Check if 'lisa' is false
if !lisa
	# If so, assign "Johnny" to variable
	out = "Johnny"
else
	# Otherwise, assign "Mark" to variable
	out = "Mark"
end

# ╔═╡ bc6a02a0-60c5-11eb-29cb-61a0c59aba34
md"Boolean logic operators `AND`, `OR`, and `XOR` are represented by infix `&&`, `||`, and the function `xor` respectively."

# ╔═╡ b1c45532-60c5-11eb-0af5-f393966e9cca
lisa && !lisa  # AND operation

# ╔═╡ b78850c0-60c5-11eb-2c40-dbb89a4b3d50
lisa || !lisa  # OR operation

# ╔═╡ a972e7ee-34b2-4930-8bea-e0faf4ff5a96
xor(lisa, !lisa) # XOR operation

# ╔═╡ e56e2f40-5f09-11eb-29a9-2db4ee699115
md"
### 3b. Loops
"

# ╔═╡ 72073c40-60c6-11eb-3fee-7b29c30c53c5
md"""#### While loops

A `while` loop executes a sequence of instructions until some termination criteria is satisfied.
"""

# ╔═╡ 9095ce60-60c6-11eb-38e4-8fe94df2e3f7
begin
	# Initialize j with value 0
	j = 0
	# Begin while loop, which iterates as long as the 'lisa' variable is true
	while lisa
		# Add 1 to current value of j. Equivalent to writing j = j + 1.
		j += 1
		# Check if j is less than or equalt o 10
		if j <= 10
			# Continue the loop if so
			continue
		else
			# Otherwise set 'lisa' as false
			lisa = false
		end
	end
end

# ╔═╡ a95edcd0-620f-11eb-083d-f5875b6a7965
j  # Check the value of variable 'j'

# ╔═╡ 591a2752-5f0a-11eb-3110-d17376a0e3a9
md"#### For loops

There are two ways to write `for` loops:
1. Expressions:"

# ╔═╡ 4faa88e0-5f0a-11eb-1d42-c51848513150
begin
	# Initialize k with value 0
	k = 0
	# Begin for loop, which takes each element of the array 'ms', referenced as the symbol 'var'.
	for var in ms
		# Add square of 'var' to current value of 'k'.
		k = k + var^2
	end
end

# ╔═╡ f90fb600-620f-11eb-3743-2fb2fc6c5937
k

# ╔═╡ 3d996449-22be-450d-becc-da6e3ac9d715
md"As a reminder, you can use the `@show` macro or `println()` function to show variables during iterations like loops."

# ╔═╡ 322b6a47-735c-41df-914c-dce7c055e7ee
begin 
	i = 0 # Initialize variable i with value 0 
	for j in 1:10
		i += j^2 # Add square of the number to current value of i
		
		@show i # Show the variable 'i' and its current value
		println(i) # Print only the value of 'i' without showing the variable
	end
	i # Display the final value of 'i' after the iteration at the top of the cell
end

# ╔═╡ 9408abc0-5f0a-11eb-35f2-cd1b2fba577b
md"""2. Comprehensions (usually nicer and more readable):
"""

# ╔═╡ 1b56b000-60c2-11eb-1878-59c6f42d7b01
md"A comprehension is similar to set-builder notation in mathematics, _e.g._:
```math
\{\ x^2 \mid x \in \{ 1,\ldots, N\}\ \}
```"

# ╔═╡ b52742e0-6210-11eb-0c91-9b91d44add7c
n = 10

# ╔═╡ ada17310-6210-11eb-07d9-b9245514422d
ps = [ x^2 for x in 1:n ] # Square each element 'x' in the range 1 ... n

# ╔═╡ ebc0b79f-e423-4460-b593-4fd58254cb60
md"""
!!! tip

	Note that summation is a common operation, and you could use Julia's `sum()` function which does the summing of the elements of an array of numbers for you.
"""

# ╔═╡ 9f4d3140-5f0a-11eb-3302-8f26d4b0a6b7
m = sum(ps) # Call function 'sum' on 'ps' to evaluate its sum

# ╔═╡ 108e4700-5f0f-11eb-34f3-2509225fb880
hint(md"This will still work if you remove the braces, and it'll be more efficient! 	
```julia
  m = sum(i^2 for i in ps)
```
This usage is called a _generator_ expression. Copy it to a new cell and try it out!")

# ╔═╡ dbc64c60-60c2-11eb-10cf-53542bfc9393
md"Let's try an array comprehension in 2 dimensions, represented by the following set-builder notation for sets ``A`` and ``B``:

```math
\{\ a^2 + b^2 \mid a \in A,\ b \in B\ \}
```"

# ╔═╡ e53a7eb0-60c2-11eb-3cf8-8ffd5bce1170
ab_sq = [ m^2 + n^2 for m in ms, n in ns ]

# ╔═╡ 0ee83402-60c3-11eb-36d5-1b957ebf3202
exercise(md"Create a 3-dimensional array in which the cubes of each element of three arrays of your choice are added.")

# ╔═╡ a0ed1080-5f08-11eb-0677-215e424d8299
md"
### 3c. Functions

Let's try to generalise our previous computations of summing natural numbers for some generic $n$, by using _functions_. 

>A function can be thought of as a machine that takes inputs (called arguments), processes them with some operations, and outputs corresponding values. Well-written functions always return the same values for the same inputs.

There are three ways to write functions:

1. 'Computer Science' syntax"

# ╔═╡ cb6cc78e-5f23-11eb-25a1-5db7e3643ceb
# Define function name 'sum_nat_num' with input argument 'n' of type 'Integer'
function sum_nat_num(n :: Integer)
	# Compute sum and assign to variable 'x'
	x = sum(1:n)

	# Return the sum
	return x
end

# ╔═╡ 21322d50-5f24-11eb-3e8e-092d8a5d1dfc
md"The `return` keyword is optional; Julia functions return the value of their last statement. The input `n`'s type is explicitly declared using the `:: Integer` syntax here. Now let's call it."

# ╔═╡ ccc71990-60a6-11eb-3a15-cfb659ca81cf
alert(md"""
Julia functions operate on the paradigm of _multiple dispatch_. Essentially, this means that you can have the same function names for different types and numbers of arguments, and the language will figure out which one to call. 
	
These function names then have associated _methods_, which dispatch based on the types of the inputs. Read more about it in the Julia documentation: [https://docs.julialang.org/en/v1/manual/methods/](https://docs.julialang.org/en/v1/manual/methods/)
""")

# ╔═╡ 7d655880-60ab-11eb-3ca3-6d436470c70b
md"_e.g._ Along with the above, we can also define the following function:"

# ╔═╡ 6f749ec0-60ab-11eb-33e7-9f8321e3b4d5
# Define function name 'sum_nat_num' with input arguments 'm','n' of Integer type
function sum_nat_num(n :: Integer, m :: Integer)
	# Compute sum of numbers from 1 to m + n (and automatically return)
	sum(1:m+n)
end

# ╔═╡ 3bd24730-5f24-11eb-34b6-b92b436ff3f0
sum_nat_num(10)

# ╔═╡ 82ac6142-60be-11eb-2dc6-9907d0f82ce8
md"Here we see that our function `sum_nat_num` has 2 methods, for our first and second implementations."

# ╔═╡ 19cf3f5a-75ce-43b7-a6df-68afc1699003
sum_nat_num(10)

# ╔═╡ b4703a20-60ab-11eb-2ac8-bdd636c0b62c
sum_nat_num(10, 5)

# ╔═╡ bcaedd30-60ac-11eb-3ee2-638d5a90dcff
md"However, if we try to call any of these functions with inputs that are not `Integer`s, then it will throw a `MethodError`."

# ╔═╡ d3c422a0-60ac-11eb-0ded-bd235955795e
# Error because 'sum_nat_num' was defined for 'Integer', and we passed Float64.
# sum_nat_num(10.)

# ╔═╡ d9512540-5f23-11eb-32f6-eb121a922fb7
md"2. 'Mathematical' syntax like $f(x) = y$"

# ╔═╡ e0f1d010-5f23-11eb-2146-5fd2ca7a3e40
# One-line definition 'sum_nat_num_math' which takes input 'n' and returns the sum.
sum_nat_num_math(n :: Integer) = sum(1:n)

# ╔═╡ 40067b00-5f24-11eb-1dec-611fc8bd6736
sum_nat_num_math(10)

# ╔═╡ 4f737f0e-5f25-11eb-305e-fd2c5053f59a
md"3. ``\lambda``-expressions (also called closures or anonymous functions)"

# ╔═╡ 5d83f5d0-5f25-11eb-0a9b-890e2b3f4ff2
sum_nat_num_λ = n -> sum(1:n)

# ╔═╡ 661468c0-5f2e-11eb-1272-774164f1904d
md"Notice how `sum_nat_num_λ` is now denoted as a _variable_ with a function assigned to it as a value. However, you cannot change its value. You can still use it like a function."

# ╔═╡ 5903aec0-5f2e-11eb-2411-25a29958ce46
sum_nat_num_λ(10)

# ╔═╡ 94f0f4a0-5f25-11eb-20b1-3d1cf2900c0b
alert(
md"""``\lambda``-expressions have a specific usage, and are not encouraged for writing generic functions. 
	
This specific usage is for defining temporary functions to perform small operations that do not require function definitions of their own generically.
""")

# ╔═╡ 048cf480-60ac-11eb-3842-3bde08089806
md"_e.g._ Summing an array of squares of natural numbers using the `sum(f, xs)` method, which calls the function `f` on each entry of the array `xs`, and then sums over it:"


# ╔═╡ 0e62a7c0-60ac-11eb-0df9-cb94b53a3f84
sum(x -> x^2, 1:n)

# ╔═╡ f6170fc0-60ac-11eb-0e4f-6d2c6ffe24b7
exercise(md"Define your own `sum_nat_num` which accepts an argument of type `Real`.")

# ╔═╡ 8bc4e432-60ac-11eb-3975-d97e7cd1b013
md"
### 3d. Broadcasting

Julia has a MATLAB-esque style of working with functions and arrays, in which a function meant for scalar values can be _broadcasted_ over an array via the use of dot (`.`) syntax, as shown below."

# ╔═╡ abc00e90-60c0-11eb-361e-59f06c853244
a^2

# ╔═╡ 7fca2e10-60ac-11eb-1602-af26e67042f9
ps.^2

# ╔═╡ b4792e40-60c0-11eb-1543-af2a0e019f9f
sum(ps.^2)

# ╔═╡ 0020f46e-8995-4d05-932d-be4feb827481
md"Let's demonstrate this operation with a function we define ourselves:"

# ╔═╡ c7ebaa72-60c0-11eb-1247-8753c461b637
doubleplusgood(x) = 2 * x + 1984

# ╔═╡ 0b8793cc-e5df-4589-8925-4334fd53c00d
md"This works on scalars."

# ╔═╡ 1fdec5a0-60c1-11eb-2dae-1d3e6868cc5f
doubleplusgood(a) # Works because adding two numbers.

# ╔═╡ a9983e6d-6cef-4f46-a97a-8d59880ba90e
md"But it doesn't work on arrays."

# ╔═╡ e95279dc-c31b-45ac-812b-c794917c84c8
# doubleplusgood(ps) # Fails because trying to add vector and number.

# ╔═╡ 84a6d613-aa5d-4718-bfa6-87584cfbfdb3
md"Use the dot syntax to broadcast it on arrays."

# ╔═╡ daeec300-60c0-11eb-03ad-7f2e6a5ac4a5
doubleplusgood.(ps) # Use broadcasting by appending '.' after the function name

# ╔═╡ 26567468-b89f-4b02-8a37-acfa5b2ebc36
md"
### 3e. Tip 1: function definition
"

# ╔═╡ de3207b8-6850-400c-a8da-4d9167f10bc0
md"""
A function definition should **only** use its input arguments for performing computations. First, let's define some (global) variables.
"""

# ╔═╡ 00fd4dcd-9986-467c-b588-d92534232c6c
begin
	V1 = 200. # Speed
	SFC = 0.55 # Specific fuel consumption
	LD = 20. # Lift-to-drag ratio
	R1 = 5000 # Some range
	R2 = 4000 # Another range
end

# ╔═╡ ac20ecb8-5429-432f-a8b9-ad5f5a8988dd
md"Here's an example of a bad function definition."

# ╔═╡ b83a265f-ca29-47b7-b3f4-9a61fa033e72
function bad_breguet_range(R, V, SFC, LD)
	WF = exp(-R1 * SFC / (V * LD))
	return WF
end

# ╔═╡ 04c079c6-5218-4f96-8794-0d91cc5f1df0
md"""This definition is bad because it calls the global variable `R1` and ignores the input argument `R`. You can tell this because `R1` variable used in this definition is underlined, while the others are not. 

!!! tip
	(`Ctrl+Click` or `Cmd+Click` on `R1` in the function definition to jump to the variable!)
"""

# ╔═╡ 1dc58ecc-6ae1-445b-91b2-5b968567e7e0
bad_breguet_range(R1, V1, SFC, LD)

# ╔═╡ a4d9635e-01cd-4326-bc92-9573baeda674
bad_breguet_range(R2, V1, SFC, LD)

# ╔═╡ af8fc523-a959-4c6a-9dd5-fc9f26b5b12b
md"Notice how if you change `R1` to `R2` while calling the function, the result doesn't change as it should."

# ╔═╡ e1ea353d-f239-46e9-846f-95263652b447
md"The following definition is good because it only depends on the input arguments. (no underlines!)"

# ╔═╡ 3277dd35-3dfb-4598-9660-b6da6b3bc928
function breguet_range(R, V, SFC, LD)
	WF = exp(-R * SFC / (V * LD)) # Evaluate weight fraction
	return WF
end

# ╔═╡ c8b76a01-11cf-4e2c-b612-a39bdbe68045
breguet_range(R1, V1, SFC, LD)

# ╔═╡ e840fee1-6ddb-4d19-b2f4-5da9ecb673c0
breguet_range(R2, V1, SFC, LD)

# ╔═╡ c54ee6b9-f0d0-4519-ae0a-f4aee75e0ef3
md"""
### 3f. Tip 2: tab completion

A convenient feature is that you can complete a function or variable by typing a part of it and pressing the `[tab]` key. Try it out on the cell below by pressing `[tab]` after placing your cursor at the end of the `breg` and `R`.

"""

# ╔═╡ eb5412da-8d64-4354-bc8c-c53441d5516f
# breg

# ╔═╡ 0fa8552d-2277-4d7f-a76d-46d1a1e7b24f
# R

# ╔═╡ 93065a9c-0016-4e4b-ae1b-4d489af658ba
md"""
---
## 4. Linear Algebra

Julia has very strong support for linear algebra, using the `LinearAlgebra` package.
"""

# ╔═╡ 51626cc2-0946-4dd8-8a64-2d6549c94356
md"
### 4a. Definitions
"

# ╔═╡ 1c794ccc-cf88-499d-99a0-8ab1f0fc24fd
md"Vectors are just one-dimensional arrays."

# ╔═╡ 99653bfb-2516-4a30-97d6-b6f1053a43b3
b = rand(5)  # Generate a random 1D vector

# ╔═╡ e35a8c3d-33f0-471b-b5b1-3dfc031630ba
typeof(b) # Check its type

# ╔═╡ cb3f994a-7035-4738-a8bd-9345869e2376
md"Matrices are two-dimensional arrays."

# ╔═╡ e562f30d-674d-42b0-8072-b9dee633715f
A = rand(5,5) # Generate a random 2D matrix

# ╔═╡ cdcb2736-d356-4f68-a27f-7f86bcac905d
md"
### 4b. Operations
"

# ╔═╡ 1b6f9660-2799-4b4a-ac92-36019c21e79d
md"Matrix multiplication"

# ╔═╡ 6ab0799f-73c2-412c-8d34-8136e3a1c489
A * b  # Matrix-vector product

# ╔═╡ 85934751-396e-43e5-85b5-868f3dc7836d
md"Matrix inversion: $A^{-1}$"

# ╔═╡ bfaba7dc-ede5-4a1f-901a-194458b33584
A^(-1)  # Matrix inverse, inv(A) also works

# ╔═╡ 5a04b000-8b31-48b4-ba05-8f0755e6b1cc
md"Solution of linear systems:

```math

Ax = b \implies x = A^{-1}b
```"

# ╔═╡ 9c97ddaa-e2dd-4eda-b9b7-8e8e18d414f0
x = A \ b # Solution of linear system Ax = b

# ╔═╡ 9a66833e-2a42-4f7d-926b-e51af09fed50
md"Vector and matrix norms:

```math
\begin{align}
	||x||, ||A||
\end{align}
```
"

# ╔═╡ 7f3a4610-cbbf-482a-9119-59db34c393ae
norm(x) # Euclidean norm of vector

# ╔═╡ 19f9c192-d736-4f72-9a76-c7fb68e34dd4
norm(A) # Euclidean norm of matrix

# ╔═╡ 0ffcf153-5b5a-4514-a0bd-9b52c59493e7
md"
### 4c. Eigen decomposition
"

# ╔═╡ b09d545a-eda1-487f-a52d-952b0a005f0c
md"An eigenvalue problem for a matrix $A$ is defined by the following equation:
```math
\mathrm{det}(\mathbf A - \lambda \mathbf I) = \mathbf 0
```
Evaluating the determinant gives a characteristic polynomial equation $p(\lambda) = 0$, whose roots $\lambda$ are the _eigenvalues_ of the matrix $A$.

The set of _eigenvectors_ $\{\mathbf x\}$ is given by the expression for each pair of eigenvalue and its corresponding eigenvector:

```math 
\mathbf A\mathbf x = \lambda\mathbf x
```

Julia provides the `eigen(A :: Matrix)` function, which will perform the computation for you and return the eigenvalues and eigenvectors.
"

# ╔═╡ c6217195-f972-42fc-b289-a610b8f7e69a
# Eigendecomposition of matrix into eigenvalues and eigenvectors 
evals, evecs = eigen(A)

# ╔═╡ c36b2c77-8ce9-4f2c-baca-12dfdced5222
md"Eigenvalues:"

# ╔═╡ a97ae53d-8010-4dcc-8647-b661d874f6f8
evals # Check eigenvalues

# ╔═╡ c745edae-bc7b-489f-bbc3-bd89fdc190e1
eigvals(A) # Function for getting only eigenvalues

# ╔═╡ e745b35e-1949-4f83-9c0a-23c6d44b4304
md"Eigenvectors:"

# ╔═╡ 234ef92a-85f3-4f49-a866-150d48714915
evecs # Check eigenvectors

# ╔═╡ 1cfeefa0-dd07-47bf-a4e8-b423e573fa6d
eigvecs(A) # Function for getting only eigenvectors

# ╔═╡ 545070b0-60bf-11eb-3a96-796bfb561610
md"""
---

## Useful Links

1. [Julia Documentation](https://docs.julialang.org/en/v1/)

2. [Linear Algebra Documentation](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/)

#### Cheatsheets

1. [MATLAB-Julia-Python comparative cheatsheet by QuantEcon group](https://cheatsheets.quantecon.org/)

2. [Fastrack to Julia](https://juliadocs.github.io/Julia-Cheat-Sheet/)
"""

# ╔═╡ efa35d10-5f08-11eb-2108-8373143309cb
# HTML width
#= html"""<style>
main {
    max-width: 100%;
}
""" =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.4"
manifest_format = "2.0"
project_hash = "4a9f6612698f71a0b8ec9e47072933e2c327202f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"
"""

# ╔═╡ Cell order:
# ╟─d0e4dac0-5edb-11eb-0312-678a24ad0573
# ╟─0f4bdbc0-5eea-11eb-35c3-d13c5d187b11
# ╟─5f6f01f0-5eee-11eb-090f-07ee55921d29
# ╟─96a0f5c8-0c73-47c4-abef-2013ce844142
# ╟─9954bd5e-db1a-4ec1-985f-86705a02f218
# ╠═7555b9fc-ced2-475b-9580-aeb3d5f360fd
# ╠═36b2d1e8-43cb-492e-8c45-d89381919403
# ╠═71a6ced3-73f0-470c-a08a-2f4362e5f5e0
# ╟─f0111d90-5f09-11eb-3977-237d140094d2
# ╟─4b5e3410-60c9-11eb-1874-f94b8c084017
# ╠═5ca1f2f5-64ee-4d6b-96bc-42a5bb63ba07
# ╠═2509e0b0-5f0d-11eb-0b86-ef2bfdc59221
# ╠═f2b0d720-60a8-11eb-10b6-cd9caa5fa211
# ╠═0d779460-60c0-11eb-2832-01d2249a84d4
# ╠═fb879b7e-60a9-11eb-02ed-17dcdc4f6e13
# ╠═c64cde23-4fb1-4879-9cf3-008eb56029b4
# ╟─12329650-60be-11eb-271e-1b4de0529ecb
# ╠═8dc81ef9-43e4-4762-b737-c975b5073b1e
# ╟─bc20e4fb-bdfd-4a94-a1a8-dd7f04a7d70f
# ╠═4764baac-63e0-4aa7-b811-44ed72178709
# ╠═757f0cbb-5ac5-4fa0-a811-69f8e3b8a494
# ╟─a1dc2650-60c7-11eb-05f3-27d797041b10
# ╠═cb5bedd0-60c7-11eb-3f23-b73a12244a5c
# ╠═f200cff0-60c7-11eb-38b8-21dbfc93d7a5
# ╠═ac9b2c55-82ff-41b3-94f9-07123f577200
# ╟─0edc6e3b-5f1c-4ef5-837f-8c8843e82cca
# ╟─7395af00-60c7-11eb-0961-7704feee1971
# ╟─76494920-5f0d-11eb-040e-63b283f2f031
# ╟─a3f4b6f0-5f23-11eb-09ba-0bed5674f6a9
# ╠═7cc1eeb0-5f0d-11eb-39c6-2715c40576b0
# ╟─567e1d90-60a8-11eb-0962-8dda3d9e9ee1
# ╠═2fcdc9c0-60a8-11eb-0ccf-f3306ae99262
# ╟─58a1bab0-60c5-11eb-0e62-13f4ac387d78
# ╠═3a890590-60a9-11eb-11ab-f7401ed79d5e
# ╟─a88d2ad0-5f23-11eb-2e9b-45a2858e2db3
# ╠═ac1c9320-5f23-11eb-1e76-cdcbc766ecec
# ╟─03b3a84e-60a8-11eb-03f1-9fcfda939baf
# ╠═39252540-60a8-11eb-15d8-29d96ef90ab9
# ╠═428b4dd0-60a8-11eb-37c7-b7a0e89073bb
# ╟─e53b73a0-60c3-11eb-2248-e9d103a0f756
# ╠═f7402f00-60c3-11eb-385c-a51fa5470d44
# ╟─c4ea57b0-60c8-11eb-378a-1909c829443b
# ╠═e92a95e0-60c8-11eb-0d12-530d3a0b7e43
# ╟─11cb4800-60c9-11eb-23f8-bb51ae2aa733
# ╟─467059e0-5f2c-11eb-3d82-ed166a16040c
# ╠═50c32c60-5f2c-11eb-1130-2f9ceb28caea
# ╟─09aae9c0-5fb4-11eb-2897-2dabe0b66efd
# ╠═86ca9e10-60a8-11eb-2875-1ba8d4efbfcc
# ╠═b2ba5422-60a8-11eb-1492-9be6c3d59ce6
# ╟─67088100-438a-4e24-9753-ca16baa8fb1d
# ╟─009c6385-e751-4ed1-ae62-e61541f960c0
# ╠═d3f781d4-4762-4ef3-b795-94a88c31088f
# ╠═b2370549-9ceb-4936-9079-4aef964e9bc3
# ╟─7fee99c9-c130-4c20-aa41-eb8803d1ae94
# ╠═4d130026-e7bf-4cc9-8192-3e4f9577b2f6
# ╟─6690c260-60a7-11eb-2559-e5ec21410cd4
# ╠═83899950-60a7-11eb-03c5-d5cf350d1de4
# ╟─891ac50e-60a7-11eb-02d7-91282f4149a5
# ╠═9bad4180-60a7-11eb-2129-b3b0e862f96a
# ╟─c30c72f2-60a7-11eb-20e0-23c12131e174
# ╠═b8cc1700-60a7-11eb-178b-6b8abb196263
# ╠═12c88f5e-60ab-11eb-36dd-5b296dabb6d1
# ╟─f2655c82-66ca-11eb-2cd6-512d918b9927
# ╠═f7d47e82-66ca-11eb-2ff3-139f7d803ed6
# ╠═01cfada8-66cb-11eb-2b97-69bb1a871daf
# ╟─0cc270d0-66cb-11eb-0471-db83d591c97c
# ╠═14eadf64-66cb-11eb-322b-194421bff2d2
# ╟─f6060b08-91d6-4114-ba43-fa6ea9a6dea7
# ╠═f2d9442b-72fa-49e2-b45d-2a352a29f247
# ╟─ae36d338-aa6e-413e-bc2b-4fcbe82d4e1f
# ╠═867ebaba-2946-4d74-a470-e44745525eec
# ╟─3e89eaa5-6314-4b13-8723-b14928a8a104
# ╠═5f88f1b6-22b6-47c4-b9d0-40b13b751037
# ╟─1adef350-0566-4e9f-9aec-d7302c0cff23
# ╠═8639b614-d32d-4b18-8200-abf10d14ceae
# ╠═ac1b7567-950f-4b3a-ac8e-ff32c4206adb
# ╟─4f4bda86-d036-4146-8f7a-2d978aee659b
# ╠═a466d409-62ee-4153-8f9e-2ce3894ee715
# ╟─9d208207-be4e-49e8-bb9f-d5a66937c2f7
# ╟─ed0d2c60-5f09-11eb-3346-73bcb62dc713
# ╠═3e238902-5f0a-11eb-27e9-61eb774d3620
# ╟─5114d4ec-9ad5-4a51-aee5-435d898b36eb
# ╠═5a7de8bb-be80-4fc5-a676-d0d2da3edc5e
# ╠═2309d252-5f0a-11eb-3db5-d16147bb8329
# ╟─bc6a02a0-60c5-11eb-29cb-61a0c59aba34
# ╠═b1c45532-60c5-11eb-0af5-f393966e9cca
# ╠═b78850c0-60c5-11eb-2c40-dbb89a4b3d50
# ╠═a972e7ee-34b2-4930-8bea-e0faf4ff5a96
# ╟─e56e2f40-5f09-11eb-29a9-2db4ee699115
# ╟─72073c40-60c6-11eb-3fee-7b29c30c53c5
# ╠═9095ce60-60c6-11eb-38e4-8fe94df2e3f7
# ╠═a95edcd0-620f-11eb-083d-f5875b6a7965
# ╟─591a2752-5f0a-11eb-3110-d17376a0e3a9
# ╠═4faa88e0-5f0a-11eb-1d42-c51848513150
# ╠═f90fb600-620f-11eb-3743-2fb2fc6c5937
# ╟─3d996449-22be-450d-becc-da6e3ac9d715
# ╠═322b6a47-735c-41df-914c-dce7c055e7ee
# ╟─9408abc0-5f0a-11eb-35f2-cd1b2fba577b
# ╟─1b56b000-60c2-11eb-1878-59c6f42d7b01
# ╠═b52742e0-6210-11eb-0c91-9b91d44add7c
# ╠═ada17310-6210-11eb-07d9-b9245514422d
# ╟─ebc0b79f-e423-4460-b593-4fd58254cb60
# ╠═9f4d3140-5f0a-11eb-3302-8f26d4b0a6b7
# ╟─108e4700-5f0f-11eb-34f3-2509225fb880
# ╟─dbc64c60-60c2-11eb-10cf-53542bfc9393
# ╠═e53a7eb0-60c2-11eb-3cf8-8ffd5bce1170
# ╟─0ee83402-60c3-11eb-36d5-1b957ebf3202
# ╟─a0ed1080-5f08-11eb-0677-215e424d8299
# ╠═cb6cc78e-5f23-11eb-25a1-5db7e3643ceb
# ╟─21322d50-5f24-11eb-3e8e-092d8a5d1dfc
# ╠═3bd24730-5f24-11eb-34b6-b92b436ff3f0
# ╟─ccc71990-60a6-11eb-3a15-cfb659ca81cf
# ╟─7d655880-60ab-11eb-3ca3-6d436470c70b
# ╠═6f749ec0-60ab-11eb-33e7-9f8321e3b4d5
# ╟─82ac6142-60be-11eb-2dc6-9907d0f82ce8
# ╠═19cf3f5a-75ce-43b7-a6df-68afc1699003
# ╠═b4703a20-60ab-11eb-2ac8-bdd636c0b62c
# ╟─bcaedd30-60ac-11eb-3ee2-638d5a90dcff
# ╠═d3c422a0-60ac-11eb-0ded-bd235955795e
# ╟─d9512540-5f23-11eb-32f6-eb121a922fb7
# ╠═e0f1d010-5f23-11eb-2146-5fd2ca7a3e40
# ╠═40067b00-5f24-11eb-1dec-611fc8bd6736
# ╟─4f737f0e-5f25-11eb-305e-fd2c5053f59a
# ╠═5d83f5d0-5f25-11eb-0a9b-890e2b3f4ff2
# ╟─661468c0-5f2e-11eb-1272-774164f1904d
# ╠═5903aec0-5f2e-11eb-2411-25a29958ce46
# ╟─94f0f4a0-5f25-11eb-20b1-3d1cf2900c0b
# ╟─048cf480-60ac-11eb-3842-3bde08089806
# ╠═0e62a7c0-60ac-11eb-0df9-cb94b53a3f84
# ╟─f6170fc0-60ac-11eb-0e4f-6d2c6ffe24b7
# ╟─8bc4e432-60ac-11eb-3975-d97e7cd1b013
# ╠═abc00e90-60c0-11eb-361e-59f06c853244
# ╠═7fca2e10-60ac-11eb-1602-af26e67042f9
# ╠═b4792e40-60c0-11eb-1543-af2a0e019f9f
# ╟─0020f46e-8995-4d05-932d-be4feb827481
# ╠═c7ebaa72-60c0-11eb-1247-8753c461b637
# ╟─0b8793cc-e5df-4589-8925-4334fd53c00d
# ╠═1fdec5a0-60c1-11eb-2dae-1d3e6868cc5f
# ╟─a9983e6d-6cef-4f46-a97a-8d59880ba90e
# ╠═e95279dc-c31b-45ac-812b-c794917c84c8
# ╟─84a6d613-aa5d-4718-bfa6-87584cfbfdb3
# ╠═daeec300-60c0-11eb-03ad-7f2e6a5ac4a5
# ╟─26567468-b89f-4b02-8a37-acfa5b2ebc36
# ╟─de3207b8-6850-400c-a8da-4d9167f10bc0
# ╠═00fd4dcd-9986-467c-b588-d92534232c6c
# ╟─ac20ecb8-5429-432f-a8b9-ad5f5a8988dd
# ╠═b83a265f-ca29-47b7-b3f4-9a61fa033e72
# ╟─04c079c6-5218-4f96-8794-0d91cc5f1df0
# ╠═1dc58ecc-6ae1-445b-91b2-5b968567e7e0
# ╠═a4d9635e-01cd-4326-bc92-9573baeda674
# ╟─af8fc523-a959-4c6a-9dd5-fc9f26b5b12b
# ╟─e1ea353d-f239-46e9-846f-95263652b447
# ╠═3277dd35-3dfb-4598-9660-b6da6b3bc928
# ╠═c8b76a01-11cf-4e2c-b612-a39bdbe68045
# ╠═e840fee1-6ddb-4d19-b2f4-5da9ecb673c0
# ╟─c54ee6b9-f0d0-4519-ae0a-f4aee75e0ef3
# ╠═eb5412da-8d64-4354-bc8c-c53441d5516f
# ╠═0fa8552d-2277-4d7f-a76d-46d1a1e7b24f
# ╟─93065a9c-0016-4e4b-ae1b-4d489af658ba
# ╠═f2953cd1-dcf6-4286-be57-6f096ebc7a44
# ╟─51626cc2-0946-4dd8-8a64-2d6549c94356
# ╟─1c794ccc-cf88-499d-99a0-8ab1f0fc24fd
# ╠═99653bfb-2516-4a30-97d6-b6f1053a43b3
# ╠═e35a8c3d-33f0-471b-b5b1-3dfc031630ba
# ╟─cb3f994a-7035-4738-a8bd-9345869e2376
# ╠═e562f30d-674d-42b0-8072-b9dee633715f
# ╟─cdcb2736-d356-4f68-a27f-7f86bcac905d
# ╟─1b6f9660-2799-4b4a-ac92-36019c21e79d
# ╠═6ab0799f-73c2-412c-8d34-8136e3a1c489
# ╟─85934751-396e-43e5-85b5-868f3dc7836d
# ╠═bfaba7dc-ede5-4a1f-901a-194458b33584
# ╟─5a04b000-8b31-48b4-ba05-8f0755e6b1cc
# ╠═9c97ddaa-e2dd-4eda-b9b7-8e8e18d414f0
# ╟─9a66833e-2a42-4f7d-926b-e51af09fed50
# ╠═7f3a4610-cbbf-482a-9119-59db34c393ae
# ╠═19f9c192-d736-4f72-9a76-c7fb68e34dd4
# ╟─0ffcf153-5b5a-4514-a0bd-9b52c59493e7
# ╟─b09d545a-eda1-487f-a52d-952b0a005f0c
# ╠═c6217195-f972-42fc-b289-a610b8f7e69a
# ╟─c36b2c77-8ce9-4f2c-baca-12dfdced5222
# ╠═a97ae53d-8010-4dcc-8647-b661d874f6f8
# ╠═c745edae-bc7b-489f-bbc3-bd89fdc190e1
# ╟─e745b35e-1949-4f83-9c0a-23c6d44b4304
# ╠═234ef92a-85f3-4f49-a866-150d48714915
# ╠═1cfeefa0-dd07-47bf-a4e8-b423e573fa6d
# ╟─545070b0-60bf-11eb-3a96-796bfb561610
# ╠═efa35d10-5f08-11eb-2108-8373143309cb
# ╠═ee5d60d0-5f0e-11eb-0574-6553f2bad5a5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
