function result = inNewEngland(stateCode)
    states = Array('MA', 'CT', 'ME', 'VT', 'NH', 'RI');
    result = states.includes(stateCode);
end