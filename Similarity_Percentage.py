from fuzzywuzzy import fuzz


def similarity(input_str_1, input_str_2):
    """
    Compare the two input strings and return a similarity percentage.
    This function uses fuzzy matching and handles variations in word order.

    Arguments:
        input_str_1 (str): The first input string to compare.
        input_str_2 (str): The second input string to compare.

    Returns:
        float: A similarity percentage between the two strings.
    """
    try:
        # Validates inputs to ensure that they're both of type string
        if not isinstance(input_str_1, str) or not isinstance(input_str_2, str):
            raise ValueError("Both inputs must be strings.")

        # Calculate the similarity using fuzzy matching and cast results to a decimal point
        sim_score = float(fuzz.token_sort_ratio(input_str_1, string2))

        return round(sim_score, 2)

    except Exception as e:
        # Log or handle errors appropriately in a real-world application
        print(f"Error: {e}")
        return 0.0


# Example Usage
if __name__ == "__main__":

    # Test case 1
    string1 = "John Smith"
    string2 = "Smith John"
    similarity_score = similarity(string1, string2)
    print(f"Similarity between '{string1}' and '{string2}': {similarity_score}%")

    # Test case 2
    string1 = "The quick brown fox"
    string2 = "The quick fox jumped over the lazy dog"
    similarity_score = similarity(string1, string2)
    print(f"Similarity between '{string1}' and '{string2}': {similarity_score}%")
