function printOwing(invoice)
outstanding = 0;

printBanner;

% calculate outstanding
for i=1:length(invoice.orders)
    o = invoice.orders(i);
    outstanding = outstanding + o.amount;
end

% record due date
today = Clock.today;
invoice.dueDate = Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);

printDetails;
end

function printBanner
console.log('***********************');
console.log('**** Customer Owes ****');
console.log('***********************');
end

function printDetails
console.log('name: %s', invoice.customer);
console.log('amount: %s', outstanding);
console.log('due: %s', invoice.dueDate.toLocaleDateString());
end
