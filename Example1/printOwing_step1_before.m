function printOwing(invoice)
outstanding = 0;

%<extract>printBanner
fprintf('***********************\n');
fprintf('**** Customer Owes ****\n');
fprintf('***********************\n');
%<\extract>

% calculate outstanding
for i=1:length(invoice.orders)
    o = invoice.orders(i);
    outstanding = outstanding + o.amount;
end

% record due date
today = Clock.today;
invoice.dueDate = Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);

%print details
fprintf('name: %s\n', invoice.customer);
fprintf('amount: %2.2f\n', outstanding);
fprintf('due: %s\n', invoice.dueDate.toLocaleDateString());
end
