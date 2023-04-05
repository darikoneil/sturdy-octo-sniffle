function load_model(app)

% function load model
filename = app.file_model;
update_log(app, 'Parsing the Model File');

% load params file first
try
    params = load(filename,'params');
    app.params = params.params;  % ends up nested
    app.ParamsLamp.Color = [0.35 0.80 0.41];
    update_log(app, 'Located Parameters');
    found_params = true;
    update_params(app);
    app.NewModelEditField.Value = app.params.name;
catch
    update_log(app,'Unable to Retrieve Params');
    app.ParamsLamp.Color = [0.87 0.27 0.27];
    found_params = false;
end

%% If Stage >= 1
% now try to load data, udf, rois/roi_styles
if found_params
    %data
    try
        data = load(filename, 'data');
        update_log(app, 'Located Dataset');
        app.data = data.data;
        app.SpikeDataLamp.Color = [0.35 0.80 0.41];
        plot_data_preview(app);
    catch
        update_log(app, 'Unable to Retrieve Data');
        app.SpikeDataLamp.Color = [0.87 0.27 0.27];
    end
    %udf
    try
        udf = load(filename, 'udf');
        update_log(app, 'Located UDFs');
        app.udf = udf.udf;
        app.UDFLamp.Color = [0.35 0.80 0.41];
        plot_data_preview(app);
    catch
        update_log(app, 'Unable to Retrieve UDFs');
        app.UDFLamp.Color = [0.87 0.27 0.27];
    end
    %rois
    
    try
        rois = load(filename, 'rois');
        update_log(app, 'Located ROIs');
        app.rois = rois.rois;
        roi_style = load(filename, 'roi_style');
        app.roi_style = roi_style.roi_style;
        app.ROIsLamp.Color = [0.35 0.80 0.41];
        plot_rois_preview(app);
    catch
        update_log(app, 'Unable to Retrieve ROIs');
        app.ROIsLamp.Color = [0.87 0.27 0.27];
    end
    
    
end

%% If Stage >= 2
if found_params && app.params.stage >= 2
    try
        models = load(filename, 'models');
        app.models = models.models;
        update_log(app, 'Located Learned Structures & Pre-Allocated Models');
        update_s_lambda_text(app);
        plot_parameter_space_structural_learning(app);
        preview_passed_structures_button_pushed(app);
        app.StructuresLamp.Color = [0.35 0.80 0.41];
    catch
        update_log(app, 'Unable to located pre-allocated models');
        app.StructuresLamp.Color = [0.87 0.27 0.27];
    end
end

%% If Stage >= 3
if found_params && app.params.stage >= 3
    try
        model_collection = load(filename, 'model_collection');
        app.model_collection = model_collection.model_collection;
        update_p_lambda_text(app);
        update_unlearned_models(app);
        update_learned_models(app);
        plot_parameter_space_parameter_estimation(app);
        plot_potentials(app);
        app.PotentialsLamp.Color = [0.35 0.80 0.41];
        update_log(app, 'Located Model Collection');
    catch
        update_log(app, 'Unable to Retrieve Model Collection');
        app.PotentialsLamp.Color = [0.87 0.27 0.27];
    end
end


%% If Stage >= 4
if found_params && app.params.stage >=4
    try
        best_model = load(filename, 'best_model');
        app.best_model = best_model.best_model;
        app.BestModelLamp.Color = [0.35 0.80 0.41];
        update_log(app, 'Located Best Model');
        update_best_model_text(app);
        plot_optimization(app, 'p_lambda', 's_lambda', 'test_likelihood');
     catch
        update_log(app,'Unable to Retrieve Selected Best Model');
        app.BestModelLamp.Color = [0.87 0.27 0.27];
    end
end

%% If Stage >= 5
if found_params && app.params.stage >= 5
    try mp = load(filename, 'model_performance');
        app.model_performance = mp.model_performance;
        update_log(app, 'Located Model Decoding Performance');
    catch
        update_log(app, 'Unable to Retrieve Model Decoding Performance');
    end
    
    try llf = load(filename, 'log_likelihood_by_frame');
        app.log_likelihood_by_frame = llf.log_likelihood_by_frame;
        update_log(app, 'Located Log Likelihood by Frame Data');
    catch
        update_log(app, 'Unable to Retrieve Log Likelihood by Frame Data');
    end
    
    try gcc = load(filename, 'global_cluster_coefficient');
        app.global_cluster_coefficient = gcc.global_cluster_coefficient;
        update_log(app, 'Locating Clustering Data');
    catch
        update_log(app, 'Unable to Retrieve Clustering Data');
    end
    
    try
        update_clustering_text(app);
    catch
        dummy = 0
    end
    
    try
        decoding_udf_selection_change_button_pushed(app); % fastest way to update these plots/text :)
    catch
        dummy = 0
    end

end
%% If Stage >= 6
% 6 only means we have calculated neuronal contributions

%% If Stage >= 7
if found_params && app.params.stage >= 7
    [app, status_val_0] = variable_loader(app, filename, 'node_performance');
    [app, status_val_1] = variable_loader(app, filename, 'random_ensemble_performance');
    [app, status_val_2] = variable_loader(app, filename, 'ensemble_nodes');
    if (status_val_0 + status_val_1 + status_val_2) == 0
        update_log(app, 'Located Identified Ensembles');
        app.EnsemblesLamp.Color=[0.35 0.8 0.41];
        plot_node_performance_distribution(app);
        plot_ensemble_coordinates(app);
        update_ensemble_text(app);
    else
        update_log(app, 'Unable to Retrieve Ensembles');
        app.EnsemblesLamp.Color=[0.87 0.27 0.27];
    
    end
end

    
%% If Stage >= 8

%% If Stage >= 9

%% IF Stage >= 10

if found_params && app.params.stage >= 9
    % We need to load ensPerf, neuronalPerformance, nodePredictions,
    % linearPerf, sizePerf
    
    %ensPerf
     try fl = load(filename, 'ensPerf');
        app.ensPerf = fl.ensPerf;
        update_log(app, 'Located Ensemble Evaluations');
        f_DA_update_ensemble_eval_text(app);
        f_DA_plot_evalEnsembles(app);
     catch
        update_log(app, 'Unable to Retrieve Ensemble Evaluations');
     end
     
     if app.params.assessNeurons
        %neuronalPerformance
         try fl = load(filename, 'neuronalPerformance');
            app.neuronalPerformance=fl.neuronalPerformance;
            update_log(app, 'Located Ensemble Evaluations - Neuronal Comparisons');
            f_DA_plot_individual_neuron_performance_EV(app);
         catch
            update_log(app, 'Unable to Retrieve Ensemble Evaluations - Neuronal Comparisons');
         end
     end
     
     %nodePredictions
     if app.params.assessNodes
         try fl = load(filename, 'nodePredictions');
            app.nodePredictions=fl.nodePredictions;
            f_DA_plot_individual_node_performance_EV(app);
            update_log(app, 'Located Ensemble Evaluations - Node Comparisons');
         catch
            update_log(app, 'Unable to Retrieve Ensemble Evaluations - Node Comparisons');
         end
     end

       %linearPerf
       if app.params.assessLinearity
         try fl = load(filename, 'linearPerf');
            app.linearPerf = fl.linearPerf;
            f_DA_plot_linear_ens(app);
            update_log(app, 'Located Ensemble Evaluations - Linear Comparisons');
         catch
            update_log(app, 'Unable to Ensemble Evaluations - Linear Comparisons');
         end
       end
       
       %sizePerf
       if app.params.assessSize
         try fl = load(filename, 'sizePerf');
            app.sizePerf = fl.sizePerf;
            update_log(app, 'Located Ensemble Evaluations - Size Comparisons');
         catch
            update_log(app, 'Unable to Ensemble Evaluations - Size Comparisons');
         end
       end
       
end

if found_params && app.params.stage >= 10
    %We need to load Node Scores, NodeThr, PCNs
     try fl = load(filename, 'PCNs');
        app.PCNs = fl.PCNs;
        update_log(app, 'Located PCNs');
        app.PCLamp.Color=[0.35 0.8 0.41];
        f_DA_update_patternCompletionText(app);
     catch
        update_log(app, 'Unable to Retrieve PCNs');
        app.PCLamp.Color=[0.87 0.27 0.27];
     end
     try fl = load(filename, 'NodeScores');
         app.NodeScores = fl.NodeScores;
         update_log(app, 'Located Node Scores');
     catch
         update_log(app, 'Unable to Retrieve Node Scores');
     end
     try fl = load(filename, 'NodeThr');
         app.NodeThr=fl.NodeThr;
         update_log(app, 'Located Node Thresholds');
         f_DA_plot_PCNs(app);
     catch
         update_log(app, 'Unable to Retrieve Node Thresholds');
     end
end

     


