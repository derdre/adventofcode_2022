INPUT_FILE=input
OUTPUT_FILE=input_proc.yaml

cp $INPUT_FILE $OUTPUT_FILE
sed -i 's/Monkey\ /monkey/g' $OUTPUT_FILE
sed -i 's/items:\ /items:\ [/g' $OUTPUT_FILE
sed -i '/Starting\ items:/ s/$/]/' $OUTPUT_FILE
sed -i 's/Starting\ items/items/g' $OUTPUT_FILE
sed -i 's/Operation/operation/g' $OUTPUT_FILE
sed -i 's/new\ \=\ //g' $OUTPUT_FILE
sed -i 's/Test/test/g' $OUTPUT_FILE
sed -i 's/divisible\ by\ //g' $OUTPUT_FILE
sed -i 's/\ \ If\ true/if_true/g' $OUTPUT_FILE
sed -i 's/\ \ If\ false/if_false/g' $OUTPUT_FILE
sed -i 's/throw\ to\ monkey\ //g' $OUTPUT_FILE


INPUT_FILE=input_small
OUTPUT_FILE=input_small_proc.yaml

cp $INPUT_FILE $OUTPUT_FILE
sed -i 's/Monkey\ /monkey/g' $OUTPUT_FILE
sed -i 's/items:\ /items:\ [/g' $OUTPUT_FILE
sed -i '/Starting\ items:/ s/$/]/' $OUTPUT_FILE
sed -i 's/Starting\ items/items/g' $OUTPUT_FILE
sed -i 's/Operation/operation/g' $OUTPUT_FILE
sed -i 's/new\ \=\ //g' $OUTPUT_FILE
sed -i 's/Test/test/g' $OUTPUT_FILE
sed -i 's/divisible\ by\ //g' $OUTPUT_FILE
sed -i 's/\ \ If\ true/if_true/g' $OUTPUT_FILE
sed -i 's/\ \ If\ false/if_false/g' $OUTPUT_FILE
sed -i 's/throw\ to\ monkey\ //g' $OUTPUT_FILE
