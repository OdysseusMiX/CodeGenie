function lines = reportLines(aCustomer)
  lines = Array;
  gatherCustomerData(lines, aCustomer); %<inline>gatherCustomerData
end

function gatherCustomerData(out, aCustomer)
  out.push({'name', aCustomer.name});
  out.push({'location', aCustomer.location});
end