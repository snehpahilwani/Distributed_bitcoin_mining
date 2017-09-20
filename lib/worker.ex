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


    def generatebitcoins(server,k,count) do
            #IO.puts "Num : #{max}"
            newstr = randomstr()
            hashstr = hashfunction(newstr)
            if String.slice(hashstr,0,k) == Enum.join(genzero("",k)) do #Genzero can be generated once in checkforKmsg and sent from there as a string. No need to generate everytime. Would optimize performance.
                #IO.puts newstr <> "\t" <> hashstr
                bitcoin_str = newstr <> "\t" <> hashstr
                bitcoin = String.to_atom(bitcoin_str)
                #sendMessage(server,{:bitcoin,bitcoin})
                if Process.alive?(server)=="yes" do
                    count = count + 1
                    send(server,{:bitcoin,bitcoin})
                    IO.puts "Sent a bitcoin. Total count: "
                    IO.puts count
                else
                    Process.exit(self(), :normal)
                end
                
            end
            generatebitcoins(server,k,count)
    end  

    def checkforKmsg() do
        IO.puts  "Checking for K msg"
        receive do
                msg -> IO.puts "I got a message! #{inspect msg}"
                server = :global.whereis_name(:server)
                generatebitcoins(server, msg,0)

                Enum.each(1..9, fn(_)->
                    spawn(fn ->
                        generatebitcoins(server, msg,0)
                        end)
                  end)
        end
        checkforKmsg()
    end

    def initateWorker(server_ip) do

        Worker.connect(server_ip)

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

    def connect(server_ip) do
        worker = "worker@"<>get_my_ip()
        Node.start(String.to_atom(worker))
        Node.set_cookie :human
        serverlink = "server@"<>server_ip
        Node.connect :"#{serverlink}"
        :global.sync()
    end

    defp get_my_ip do
        {os, _} = :os.type
        {:ok, ifs} = :inet.getif()
        ips = for {ip, _, _} <- ifs, do: to_string(:inet.ntoa(ip))
        if Atom.to_string(os) == "unix" do
        hd(ips)
      else
        List.last(ips)
      end
     end

end