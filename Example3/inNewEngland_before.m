function result = inNewEngland(aCustomer)
    states = Array('MA', 'CT', 'ME', 'VT', 'NH', 'RI');
    result = states.includes(aCustomer.address.state); %<replaceInput>aCustomer::stateCode
end