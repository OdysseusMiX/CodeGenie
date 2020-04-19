function changeParameterExample

customer1.address.state = 'CT';
customer2.address.state = 'FL';

someCustomers = Array(customer1, customer2);

newEnglanders = someCustomers.filter(@(c) inNewEngland(c));
end