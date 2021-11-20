tic
filename = "input.dat";

fildID = fopen(filename, 'r');

n_task = str2num(fgetl(fildID));
tau = str2num(fgetl(fildID));
data = fscanf(fildID, "%f %f %f\n", [3 Inf]);

temp = 100;
r = 0.5;
global n_task tau data response_time;
CAN_timing_analysis(); best_data = data; best_response_time = sum(response_time);
prev_response_time = inf;
for n_iter = 1 : 1000
    SA_iter(0);
    valid = CAN_timing_analysis();
    if(valid && (sum(response_time) < sum(prev_response_time))) 
        best_data = data; best_response_time = sum(response_time); 
        prev_response_time = response_time;
    else 
        if(~valid) SA_iter(1);
        elseif(sum(response_time) > sum(prev_response_time))
            p = exp((sum(prev_response_time)-sum(response_time))/temp);
            if(p > 1) p = 1; end
            if(rand(1)<p) prev_response_time = response_time;
            else SA_iter(1);
            end
        end
    end
    temp = r * temp;
end
fprintf("%d\n",best_data(1,:))
% fprintf("%d %f %f\n",best_data)
CAN_timing_analysis(); sum(response_time)
toc

function SA_iter(reverse)
    global n_task data;
    persistent idx_1 idx_2;
    if(reverse)
        data(1,[idx_1 idx_2]) = data(1,[idx_2 idx_1]);
    else
        idx_1 = randi(n_task);
        idx_2 = randi(n_task);
        if(idx_2 ~= idx_1) data(1,[idx_1 idx_2]) = data(1,[idx_2 idx_1]); end
    end
end


function valid = CAN_timing_analysis()
    global n_task tau data response_time;
    priority = data(1,:);
    [~, permut] = sort(priority);
    time = data(2,permut);
    period = data(3,permut);
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
    valid = (prod(period > response_time) == 1);
end