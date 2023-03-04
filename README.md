# Interest-Calculation-Procedure

Pre-requisite : You need to have relevant tables for account details and transactions done by each account.

In this I have used plpgsql for calculating monthly interest of an account for 6 months and then add the accumulated interest to the current balance of the account.
I have used 1 procedure and four functions here they are:

1.addint() procedure : To fetch the account numbers and add the respective interests to their current balances.

2.calint() function : To calculate the monthly interest for 6 months if the account is atleast 6  months old. Else the interest is calculated for the number of months passed from the opening of the account.

3.minbal() function : To calculate the minimum balance of an account for that particular month. The minimum balance for that month will be used as the principal amount for calculating interest for that month.

4.curbal() function : To calculate the balance of the account at the last day of that month. This will be used as a reference to calculate the minimum balance for that month.

5.monbet() function : This function is used to calculate the months between the account opening date and the current date. This function checks if the months between the account opening date and the current date is greater than 6 then the interest is calculated for 6 months, otherwise the interest is calculated only for the the number of months the account is active if the account is opened less than 6 months from the current date. 
