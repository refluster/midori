echo 'date,humidity,celsius,illumination,moisture' > out.csv
cat *01min.csv | sed '/^date/d' >> out.csv
