defmodule Worker do
    
    # function to generate random string with gatorlink id appended
    def randomstr(length \\ 15) do
        Enum.join(["spahilwani;",:crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)])
    end

    # Generate hash for given string using SHA256
    def hashfunction(str) do
        :crypto.hash(:sha256, str) |> Base.encode16 
    end
    
    #Generates string of k number of zeros
    def genzero(x,k) do
        for _y<-1..k,
        do: x<> "0" 
    end

    #Generate bitcoin by trying out the strings and send to server if the valid bitcoin string
    def generatebitcoins(server,k) do
            newstr = randomstr()
            hashstr = hashfunction(newstr)
            if String.slice(hashstr,0,k) == Enum.join(genzero("",k)) do 
                bitcoin_str = newstr <> "\t" <> hashstr
                bitcoin = String.to_atom(bitcoin_str)
                #Sending the found bitcoin to the server.
                send(server,{:bitcoin,bitcoin})
            end
            generatebitcoins(server,k)
    end  

    def checkforKmsg() do
        #"Requesting server for k"
        receive do
                #Got a message from server with k value
                server = :global.whereis_name(:server)

                #Spawning more workers to computer bitcoins parallelly and use more CPU cores.
                Enum.each(1..9, fn(_)->
                    spawn(fn ->
                        generatebitcoins(server, msg)
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
        :global.register_name(client_atom, worker_pid)
        :global.sync()
        server = :global.whereis_name(:server)
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