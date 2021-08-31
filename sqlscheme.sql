CREATE TABLE `races` (
  `identifier` varchar(80) NOT NULL,
  `name` varchar(255) NOT NULL,
  `race` varchar(100) NOT NULL,
  `lastTime` text NOT NULL,
  `bestTime` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `races`
  ADD PRIMARY KEY (`identifier`);
COMMIT;
