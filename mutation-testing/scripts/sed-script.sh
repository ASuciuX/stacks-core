
FILE="../packages-output/stx-genesis/caught.txt"

var_1="stx-genesis/src/lib.rs"
var_2="replace <impl Iterator for LinePairReader>::next -> Option<Self::Item> with Some(Default::default())"

# Escape the variables for use in a sed pattern
escaped_var_1=$(echo "$var_1" | sed -E 's/([][\/$*.^|])/\\&/g')
escaped_var_2=$(echo "$var_2" | sed -E 's/([][\/$*.^|])/\\&/g')

# Use sed to remove lines matching the pattern
sed "/$escaped_var_1:[0-9]+:$escaped_var_2/d" "$FILE" > "$FILE"
# :[0-9]+:
# sed -i "/$regex/d" "$FILE"
