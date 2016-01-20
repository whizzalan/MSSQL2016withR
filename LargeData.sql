drop proc if exists generate_rx_model;
go
create procedure generate_rx_model
as
begin
	execute sp_execute_external_script
	  @language = N'R'
	, @script = N'
		require("RevoScaleR");
		#trained_model <- head(airLine_rx_data);
		model.rxLinMod <- rxLinMod(ArrDelay ~ CRSDepTime + DayOfWeek - 1, airLine_rx_data)
		trained_model <- data.frame(payload = as.raw(serialize(model.rxLinMod, connection=NULL)));'
	, @input_data_1 = N'select * from [master].[dbo].[AirlineLarge]'
	, @input_data_1_name = N'airLine_rx_data'
	, @output_data_1_name = N'trained_model'
	with result sets ((model varbinary(max)));
end;
go

-- select top(10) * from [master].[dbo].[AirlineLarge];

drop table if exists rx_models;
create table rx_models (
	model_name varchar(30) not null default('default model') primary key,
	model varbinary(max) not null
);
go

-- truncate table rx_models;
insert into rx_models(model)
exec generate_rx_model;
update rx_models set model_name = 'rmodel.rxLinMod' where model_name = 'default model';
select * from rx_models;
go