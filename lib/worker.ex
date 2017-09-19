defmodule Worker do
    
    def randomstr(length \\ 15) do
        Enum.join(["spahilwani;",:crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)])
    end

    def hashfunction(str) do
        :crypto.hash(:sha256, str) |> Base.encode16 
    end
    
    def genzero(x,k) do
        for _y<-1..k,
        do: x<> "0" 
    end

    
    # def loop(0,_), do: nil

    def generatebitcoins(server,k,count) do
            #IO.puts "Num : #{max}"
            newstr = randomstr()
            hashstr = hashfunction(newstr)
            if String.slice(hashstr,0,k) == Enum.join(genzero("",k)) do #Genzero can be generated once in checkforKmsg and sent from there as a string. No need to generate everytime. Would optimize performance.
                #IO.puts newstr <> "\t" <> hashstr
                bitcoin_str = newstr <> "\t" <> hashstr
                bitcoin = String.to_atom(bitcoin_str)
                #sendMessage(server,{:bitcoin,bitcoin})
                if Process.alive?(server) do
                    send(server,{:bitcoin,bitcoin})
                end
                count = count + 1
                IO.puts "Sent a bitcoin. Total count: "
                IO.puts count
            end
            generatebitcoins(server,k,count)
    end  

    def checkforKmsg() do
        IO.puts  "Checking for K msg"
        receive do
                msg -> IO.puts "I got a message! #{inspect msg}"
                server = :global.whereis_name(:server)
                generatebitcoins(server, msg,0)
        end
        checkforKmsg()
    end

    def initateWorker() do

        Worker.connect()

        worker_pid = spawn(fn ->
            checkforKmsg()
        end)
        client_string = Enum.join(["worker",:crypto.strong_rand_bytes(5) |> Base.encode64 |> binary_part(0, 5)])
        client_atom = String.to_atom(client_string)
        IO.inspect worker_pid
        IO.puts Process.alive?(worker_pid)
        IO.puts :global.register_name(client_atom, worker_pid)
        :global.sync()
        IO.inspect(:global.whereis_name(client_atom))
        server = :global.whereis_name(:server)
        #sendMessage(server,{:ready,client_atom})
        send(server, {:ready,client_atom})
        Process.sleep(:infinity)
    end

    def connect() do
        Node.start :'worker@192.168.0.104' #this is the IP of the machine on which you run the code
        Node.set_cookie :human
        Node.connect :'server@192.168.0.100' #Enum.join
        :global.sync()
    end

    # def sendMessage(server,msg) do
    #     #:global.sync()
    #     IO.puts "Working here 2a"
    #     #server = :global.whereis_name(:server)
    #     IO.puts "Working here 2b"
    #     IO.inspect(server)
    #     #IO.inspect(Node.list)
    #     send(server, msg)
    #     IO.puts "Working here3 "
    # end

end