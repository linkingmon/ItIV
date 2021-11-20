filename = "input.dat";

fildID = fopen(filename, 'r');

n_task = str2num(fgetl(fildID));
tau = str2num(fgetl(fildID));
data = fscanf(fildID, "%f %f %f\n", [3 Inf]);
priority = data(1,:);
time = data(2,:);
period = data(3,:);

response_time = [];
for i_task = 1 : n_task
    block_time = max(time(i_task:end));
    Q = block_time;
    while true
        if(i_task == 1) RHS = block_time;
        else RHS = block_time + sum(ceil((Q+tau)./period(1:i_task-1)).*time(1:i_task-1)); 
        end
        if(Q == RHS) response_time(i_task) = Q + time(i_task); break; end
        Q = RHS;
    end
end

fprintf("%f\n",response_time)