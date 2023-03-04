--accounts fetching
create or replace procedure addint()
as $$
declare
        fetc cursor for select accno from bh_accounts ;  --fetch all accounts from the accounts table
        interest numeric(5,2):=0;                                     -- to store  accumulated interest of an account
        aid int;
begin
	if (extract(month from now()) in (3,9)) then
    	open fetc;
        loop 
        	fetch fetc into aid;
        	exit when not found;
        	interest=calint(aid);                                                                                     --function to calculate interest
        	update bh_accounts set currentbal=currentbal+interest where accno=aid; --add interest to current balance
            insert into bhaskar_tr values(aid,current_date,'credit',interest);
        end loop;
        close fetc;
     else
     	raise notice 'Cannot add interest in this month. Interests for the accounts is calculated only in March and September';
     end if;
end;
$$ language plpgsql;

--calculate interest
create or replace function calint(ano int)
returns numeric(5,2)
as $$
declare
        interest numeric(5,2):=0;			--for storing interest 
        r numeric(3,1):=4.2;	                               -- rate of interest
        mb int:=0;                                                        -- for storing principal amount 
        stm date;
        edm date;
        mbetw int:=(select monbet(ano));
begin
       for i in 0..mbetw-1 loop                                     
            stm=((date_trunc('month',(current_date-(i+1||'month')::interval))+interval'9 days')::date);
            edm=((date_trunc('month',(current_date -(i||'month')::interval))-interval'1 days')::date);
            mb=minibal(ano,stm,edm);			         -- function to calculate principal
            interest=interest+(mb*r)/1200;           -- monthly interest so divide by 12 and also to aggregrate interest of each month
        end loop;
        return interest;
end;
$$ language plpgsql;

--to calculate minimum balance

create or replace function minibal(ano int,st date,ed date)   
returns int
as $$
declare
        trc cursor for select tr_type,tr_amount from bhaskar_tr where accno=ano and tr_date between st and ed order by tr_date desc;
        cb int:=(select curbal(ano,ed));
        mb int:=0;
        ttype varchar(2);
        tamt int;
begin
	open trc;
    loop
        fetch trc into ttype,tamt;
        exit when not found;
        if (ttype='C') then
        	cb=cb-tamt;
        else
           cb=cb+tamt;
        end if;
        if(cb<mb) then
        	mb=cb;
        end if;
     end loop;
     close trc;
     return mb;
end;
$$ language plpgsql;

-- to calculate current balance
create or replace function curbal(ano int,ed date)
returns int
as $$
declare
        tcb cursor for select tr_type,tr_amount from bhaskar_tr where accno=ano and tr_date>ed order by tr_date desc;
        cb int:=(select currentbal from bh_accounts where accno=ano);
        ttype varchar(2);
        tamt int;
begin
	open tcb;
    loop
        fetch tcb into ttype,tamt;
        exit when not found;
        if (ttype='C') then
        	cb=cb-tamt;
        else
           cb=cb+tamt;
        end if;
     end loop;
     close tcb;
     return cb;
end;
$$ language plpgsql;

--months between op_date and current_date
create or replace function monbet(ano int)
returns int
as $$
declare
       monbw int:=(select extract(year from age(op_date))*12+extract(month from age(op_date))+round(extract(day from age(op_date))/30.0) as months from bh_accounts where accno=ano);
        days int:=(select extract(day from op_date) from bh_accounts where accno=ano);
begin 
	if monbw>6 then 
    	return 6;
    else 
        if days>10 then
        	return monbw-1;
        else
        	return monbw;
        end if; 
    end if;
end;
$$ language plpgsql;

call addint();		