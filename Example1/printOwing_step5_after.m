function printOwing(invoice)

printBanner;

outstanding = calculateOutstanding(invoice);

invoice = recordDueDate(invoice);

printDetails(invoice, outstanding);
end

function printBanner
fprintf('***********************\n');
fprintf('**** Customer Owes ****\n');
fprintf('***********************\n');
end

function printDetails(invoice, outstanding)
fprintf('name: %s\n', invoice.customer);
fprintf('amount: %2.2f\n', outstanding);
fprintf('due: %s\n', invoice.dueDate.toLocaleDateString());
end

function outstanding = calculateOutstanding(invoice)
outstanding = 0;
for i=1:length(invoice.orders)
    o = invoice.orders(i);
    outstanding = outstanding + o.amount;
end
end

function invoice = recordDueDate(invoice)
today = Clock.today;
invoice.dueDate = Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);
end
