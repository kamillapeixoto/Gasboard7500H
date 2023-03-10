function [concentration, flow, temperature, status] = read_o2(s, mode)
                                 

switch mode

    case 1 %Default mode

        % Request Data
        keyword = [0x11 0x01 0x01 0xED];
        flush(s);
        write(s,keyword,"uint8"); % This line is necessary only if a sample
                                  % time different from 0.5s is used

        % Read Data
        data_size = 12;
        raw_data = read(s,data_size,"uint8");

        % In case it is not able to read it
        if (size(raw_data)<data_size)
            data = zeros(1,data_size);
            status = 0;
        else
            data   = raw_data(4:11);
            status = 1;  
        end

        % Calculate parameters
        concentration = (data(1)*256 + data(2))/10; %(Vol %)
        flow          = (data(3)*256 + data(4))/10; %(L/min)
        temperature   = (data(5)*256 + data(6))/10; %(℃)

    case 2 % Expanded range

        % Request Data
        keyword = [0x11 0x02 0x02 0x00 0xEB];
        flush(s);
        write(s,keyword,"uint8")
        
        % Read Data
        data_size = 15;
        raw_data = read(s,data_size,"uint8");




        % In case it is not able to read it
        if (size(raw_data)<data_size)
            data = zeros(1,data_size);
            status = 1;
        else
            data     = raw_data(5:14);
            status = 0;  
        end

        
        % Calculate parameters
        concentration = (data(7)*256 + data(8))/10; %(Vol %)
        flow          = (data(9)*256 + data(10))/10; %(L/min)
        temperature   = (data(5)*256 + data(6))/10; %(℃)

    

end

end