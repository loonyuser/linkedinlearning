function transform(line) {
	 var values = line.split(',');
	 var obj = new Object();
	 obj.Order_ID = values[0];
	 obj.Amount = values[1];
	 obj.Profit = values[2];
	 obj.Quantity = values[3];
	 obj.Category = values[4];
	 obj.Sub_Category = values[5];
	 var jsonString = JSON.stringify(obj);
	 return jsonString;
}