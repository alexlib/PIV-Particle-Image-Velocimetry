function build_graphs_group(data)
%build_graphs_group Визуализация результатов сравнения для всех сценариев
%   Позволяет визуализировать динамическое число сценариев

[N,P] = size(data,1:2);
x = 1:N;

% Среднеквадратическое отклонение
tiledlayout(2,1)
ax1 = nexttile;
for p = 1:P
    plot(x,data(:,p,1),"LineWidth",2.0);
    hold on
end
title('Среднеквадратическое отклонение')
grid on
xlabel('Номер пары изображений','FontWeight','bold')
ylabel('СКО, пикс.','FontWeight','bold')

% Максимум отклонения
ax2 = nexttile;
for p = 1:P
    plot(x,data(:,p,2),"LineWidth",2.0);
    hold on
end
title('Максимум отклонения')
grid on
xlabel('Номер пары изображений','FontWeight','bold')
ylabel('Max, пикс.','FontWeight','bold')

% Формирование легенды
legent_text = strings(P,1);
for p = 1:P
    legent_text(p) = strcat("processing ",string(p));
end
legend(ax1,legent_text,'Location','bestoutside')
legend(ax2,legent_text,'Location','bestoutside')

end