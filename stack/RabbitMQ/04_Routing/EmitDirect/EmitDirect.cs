using System;
using System.Text;
using System.Linq;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

class EmitDirect
{
    public static void Main(string[] args)
    {
        // create factory, connection and channel
        var factory = new ConnectionFactory() { HostName = "localhost" };
        using (var connection = factory.CreateConnection())
        using (var channel = connection.CreateModel())
        {
            // declare the type of exchange
            channel.ExchangeDeclare(exchange: "direct_logs",
                                    type: "direct");

            // prepare message severity
            var severity = (args.Length > 0) ? args[0] : "info";

            // prepare message
            var message = (args.Length > 1)
                          ? string.Join(" ", args.Skip( 1 ).ToArray())
                          : "Hello World";

            // prepare body
            var body = Encoding.UTF8.GetBytes(message);

            // prepare publishing
            channel.BasicPublish(exchange: "direct_logs",
                                routingKey: severity,
                                basicProperties: null,
                                body: body);

            // print something to console
            Console.WriteLine("[x] Sent '{0}':'{1}'", severity, message);
        }

        Console.WriteLine("Press [enter] to exit");
        Console.ReadLine();
    }
}


