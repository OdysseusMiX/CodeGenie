function printOwing(invoice)
outstanding = 0;

fprintf('***********************\n');
fprintf('**** Customer Owes ****\n');
fprintf('***********************\n');

% calculate outstanding
for i=1:length(invoice.orders)
    o = invoice.orders(i);
    outstanding = outstanding + o.amount;
end

today = Clock.today;
invoice.dueDate = Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);

fprintf('name: %s\n', invoice.customer);
fprintf('amount: %2.2f\n', outstanding);
fprintf('due: %s\n', invoice.dueDate.toLocaleDateString());

end

