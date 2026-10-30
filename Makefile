# Compiler
CXX = g++
# Compiler flags
CXXFLAGS = -Wall -std=c++17
# Include directories
INCLUDES = -I.

# Source files
SRC = Init.cpp Machine.cpp main.cpp Scheduler.cpp Simulator.cpp Task.cpp VM.cpp

# Object files
OBJ = $(SRC:.cpp=.o)

# Executable
TARGET = simulator

TESTS_DIR ?= tests

SHELL := /bin/bash

.PHONY: all clean test

# Default target
all: $(TARGET)

# Default target
scheduler: $(OBJ)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o scheduler $(OBJ)

# Build target
$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(OBJ)

# Compile source files into object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Run every file under $(TESTS_DIR), including subdirectories
test: $(TARGET)
	@fail=0; tmp=$$(mktemp); \
	while IFS= read -r -d '' -u 3 t; do \
		echo "=== $$t ==="; \
		./$(TARGET) "$$t" 2>&1 | tee "$$tmp"; rc=$${PIPESTATUS[0]}; \
		if [ $$rc -ne 0 ] || grep -q "Caught an exception" "$$tmp"; then \
			echo "FAILED: $$t"; fail=$$((fail+1)); \
		fi; \
	done 3< <(find $(TESTS_DIR) -type f -print0 | sort -z); \
	rm -f "$$tmp"; \
	echo "$$fail test(s) failed"; \
	[ $$fail -eq 0 ]

# Clean up build files
clean:
	rm -f $(OBJ) $(TARGET)