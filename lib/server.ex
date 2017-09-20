defmodule Server do
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

    # This process is meant for communication from server to workers.
    # Replies with appropriate messages in the mailbox.
    def talktoworkers(k) do
        receive do
            {:bitcoin, response} ->
                IO.puts "Bitcoin from worker : #{inspect response}"
            {:ready, client} ->
                # When a worker initiates new connection we send the value k
                :global.sync()
                send(:global.whereis_name(client), k)
                IO.puts client
                IO.inspect :global.whereis_name(client)
        end
        talktoworkers(k)
    end 
    

    # This process generates bitcoin mining processes in the server.
    def mineCoins(k) do
            Enum.each(1..9, fn(_)->
                spawn(fn ->
                    Server.generatebitcoinsParallel(k)
                    end)
              end)
    end  

    #Definition of single process mining bitcoin
    def generatebitcoinsParallel(k) do
        newstr = randomstr()
        hashstr = hashfunction(newstr)
        if String.slice(hashstr,0,k) == Enum.join(genzero("",k)) do 
            IO.puts newstr <> "\t" <> hashstr
        end
        generatebitcoinsParallel(k)
    end


end



